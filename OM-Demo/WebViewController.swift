//
//  WebViewController.swift
//  OM-Demo
//
//  Created by Alex Chugunov on 9/17/17.
//

import UIKit
import WebKit
import MediaPlayer
import OMSDK_IAB

class WebViewController: OMDemoViewController {
    var webView: WKWebView?
    var creativeDownloadTask: URLSessionDownloadTask?
    var isPrerendering: Bool = false
    
    var creativeURL: URL {
        guard let creativeURL = URL(string: Constants.ServerResource.bannerAd.rawValue) else {
            fatalError("Unable to access resource: \(Constants.ServerResource.bannerAd)")
        }
        return creativeURL
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = createWebView()
        title = "300x250 Display"
    }
    
    override func displayAd() {
        super.displayAd()
        if isPrerendering {
            startViewabilityMeasurement()
        } else {
            // Temporary workaround for https://github.com/InteractiveAdvertisingBureau/Open-Measurement-SDKiOS/issues/21
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.startViewabilityMeasurement()
            }
        }
    }
    
    func createWebView() -> WKWebView {
        let webView = WKWebView(frame: adView.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let loadingStatusScript = WKUserScript(source: Constants.webViewLoadingStatusHandler,
                                               injectionTime: .atDocumentStart,
                                               forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(loadingStatusScript)
        webView.configuration.userContentController.add(self, name: Constants.webViewHandlerName)
        
        return webView
    }
    
    override func destroyAd() {
        self.destroyWebView()
    }
    
    func destroyWebView() {
        guard let webView = webView else {
            return
        }
        // Temporary workaround for https://github.com/InteractiveAdvertisingBureau/Open-Measurement-SDKiOS/issues/22
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
            webView.navigationDelegate = nil
            webView.scrollView.isScrollEnabled = false
            webView.uiDelegate = nil
            webView.configuration.userContentController.removeScriptMessageHandler(forName: Constants.webViewHandlerName)
            webView.configuration.userContentController.removeAllUserScripts()
            webView.stopLoading()
            
            webView.removeFromSuperview()
            self.webView = nil
            self.webView = self.createWebView()
        }
    }
    
    override func createAdSession() -> OMIDIABAdSession? {
        let partnerName = Bundle.main.bundleIdentifier ?? "com.omid-partner"
        let partnerVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        guard let partner = OMIDIABPartner(name: partnerName, versionString: partnerVersion ?? "1.0")
            else {
                fatalError("Unable to initialize OMID partner")
        }
        
        guard let webView = webView else {
            fatalError("WebView is not initialized")
        }
        
        do {
            //Create web view context
            let context = try OMIDIABAdSessionContext(partner: partner, webView: webView, customReferenceIdentifier: nil)
            
            //Create ad session configuration
            let configuration = try OMIDIABAdSessionConfiguration(impressionOwner: OMIDOwner.javaScriptOwner, videoEventsOwner: OMIDOwner.noneOwner, isolateVerificationScripts: false)
            
            //Create ad session
            let session = try OMIDIABAdSession(configuration: configuration, adSessionContext: context)
            
            //Provide main ad view for measurement
            session.mainAdView = webView
            
            //Register any views that are intentionally overlaying the main view
            session.addFriendlyObstruction(closeButton)
            return session
        } catch {
            fatalError("Unable to instantiate ad session: \(error)")
        }
        return nil
    }
}

// MARK: - Outlet Handlers
extension WebViewController {
    /**
     Displays ad container with the webview after rendering completes.
     */
    
    @IBAction func displayAfterRendering(_ sender: AnyObject) {
        guard !displayInProgress else {
            return
        }
        
        displayInProgress = true
        statusLabel.isHidden = false
        isPrerendering = true
        
        fetchCreative(creativeURL) { (HTML) in
            self.renderAd(withHTML: HTML)
        }
    }
    
    /**
     Displays ad container with the webview before rendering starts.
     */
    
    @IBAction func displayImmediately(_ sender: AnyObject) {
        guard !displayInProgress else {
            return
        }
        
        displayInProgress = true
        statusLabel.isHidden = false
        isPrerendering = false
        fetchCreative(creativeURL) { (HTML) in
            self.displayAd()
            self.renderAd(withHTML: HTML)
        }
    }
}

// MARK: - WebView lifecycle
extension WebViewController {
    /**
     Asynchronously loads creative from a remote URL or local file URL
     
     - Parameters:
     - creativeURL: URL to creative (either remote or local)
     - completionHandler: completion handler that is called when creative loads successfully
     - content: contents of the creative
     */
    func fetchCreative(_ creativeURL: URL!, _ completionHandler: @escaping (_ content: String) -> ()) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Fetching..."
        }
        NSLog("Fetching creative.")
        DispatchQueue.global().async {
            if creativeURL.isFileURL {
                let content = try! String(contentsOf: creativeURL)
                DispatchQueue.main.async {
                    NSLog("Did finish fetching creative.")
                    completionHandler(content)
                }
            } else {
                NSLog("Loading creative from remote URL.")
                self.creativeDownloadTask = URLSession.shared.downloadTask(with: creativeURL) {
                    [weak self] (fileURL, response, error) in
                    guard let fileURL = fileURL else {
                        fatalError("Unable to fetch creative from remote URL: \(creativeURL). Error: \(String(describing: error))")
                    }
                    
                    print(response ?? "no response")
                    print(error ?? "no error")
                    NSLog("Finished loading creative from remote URL.")
                    self?.fetchCreative(fileURL, completionHandler)
                }
                self.creativeDownloadTask?.resume()
            }
        }
    }
    
    func injectOMID(intoHTML HTML: String) -> String {
        do {
            //Load omid service asset
            guard let url = URL(string: Constants.ServerResource.omsdkjs.rawValue) else { fatalError("Unable to inject OMID JS into ad creative") }
            
            let OMIDJSService = try String(contentsOf: url)
            
            let creativeWithOMID = try OMIDIABScriptInjector.injectScriptContent(OMIDJSService,
                                                                                 intoHTML:HTML)
            return creativeWithOMID
        } catch {
            fatalError("Unable to inject OMID JS into ad creative: \(error)")
        }
    }
    
    func renderAd(withHTML HTML: String) {
        //Inject OMID JS service script into HTML creative
        let creative = injectOMID(intoHTML: HTML)
        
        statusLabel.text = "Rendering..."
        print(Constants.webViewLoadingStatusHandler)
        
        if let webView = webView {
            adView.addSubview(webView)
            adView.sendSubview(toBack: webView)
            webView.loadHTMLString(creative, baseURL: URL(string: Constants.ServerResource.baseURL.rawValue))
        }
    }
}

// MARK: - WKScriptMessageHandler
extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == Constants.webViewHandlerName,
            let body = message.body as? String,
            body == Constants.webViewDidFinishRenderingMessage
            else {
                return
        }
        
        NSLog("WebView has finished rendering")
        if (isPrerendering) {
            displayAd()
        }
    }
}

