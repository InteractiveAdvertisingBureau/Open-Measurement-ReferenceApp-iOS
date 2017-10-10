//
//  WebViewController.swift
//  OM-Demo
//
//  Created by Alex Chugunov on 9/17/17.
//

import UIKit
import WebKit

let OMIDAPIVersion = "{\"v\":\"1.0.0\"}"

let webViewHandlerName = "loadingStatusHandler"
let webViewDidFinishRenderingMessage = "didFinishRendering"

// JavaScript to handle web view finish rendering event
let webViewLoadingStatusHandler = """
(function() {
    this.didFinishRendering = function() {
        console.log('Creative did finish rendering.');
        window.webkit.messageHandlers.\(webViewHandlerName).postMessage('\(webViewDidFinishRenderingMessage)');
    };
	window.addEventListener('load', function () {
        this.didFinishRendering();
	});
}());
"""

class WebViewController: UIViewController {
    @IBOutlet var adContainerView: UIView!
    @IBOutlet var adView: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var closeButton: UIButton!

    var webView: WKWebView?
    var isPrerendering: Bool = false
    var adSession: OMIDAdSession?
    var displayInProgress = false
    var creativeDownloadTask: URLSessionDownloadTask?

    var creativeURL: URL {
        fatalError("Not implemented")
    }

    func willDisplayAd() {}

    func willDismissAd() {}

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = createWebView()
        title = "300x250 Display"
        adContainerView.isHidden = true
        adContainerView.alpha = 0.0
        statusLabel.isHidden = true
    }

    func createWebView() -> WKWebView {
        let webView = WKWebView(frame: adView.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let loadingStatusScript = WKUserScript(source: webViewLoadingStatusHandler,
                                               injectionTime: .atDocumentStart,
                                               forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(loadingStatusScript)
        webView.configuration.userContentController.add(self, name: webViewHandlerName)

        return webView
    }

    func destroyWebView() {
        guard let webView = webView else {
            return
        }

        webView.navigationDelegate = nil
        webView.scrollView.isScrollEnabled = false
        webView.uiDelegate = nil
        webView.configuration.userContentController.removeScriptMessageHandler(forName: webViewHandlerName)
        webView.configuration.userContentController.removeAllUserScripts()
        webView.stopLoading()

        webView.removeFromSuperview()
        self.webView = nil
        self.webView = createWebView()
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
    
    @IBAction func displayImmediatelly(_ sender: AnyObject) {
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

    /**
     Dismisses ad container and resets the webview
     */

    @IBAction func dismissAd() {
        guard !adContainerView.isHidden else {
            return
        }

        willDismissAd()
        NSLog("Ad Container is about to be dismissed")
        UIView.animate(withDuration: 0.5, animations: {
            self.adContainerView.alpha = 0.0
        }) { (completed) in
            NSLog("Ad Container is hidden")

            self.finishViewabilityMeasurement()
            self.destroyWebView()
            self.adContainerView.isHidden = true
            self.displayInProgress = false
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

                    NSLog("Finished loading creative from remote URL.")
                    self?.fetchCreative(fileURL, completionHandler)
                }
                self.creativeDownloadTask?.resume()
            }
        }
    }

    func startViewabilityMeasurement() {
        guard prepareOMID() else {
            fatalError("OMID is not active")
        }

        NSLog("Starting measurement session now")
        adSession = createAdSession()
        adSession?.start()
    }

    func finishViewabilityMeasurement() {
        NSLog("Ending measurement session now")
        self.adSession?.finish()
    }

    func prepareOMID() -> Bool {
        if OMIDSDK.sharedInstance.isActive {
            return true
        }

        guard OMIDSDK.is(compatibleWithOMIDAPIVersion: OMIDAPIVersion) else {
            fatalError("OMID SDK is not compatible with OMID API version")
        }

        do {
            try OMIDSDK.sharedInstance.activate(withOMIDAPIVersion: OMIDAPIVersion)
        } catch {
            fatalError("Unable to activate OMID SDK: \(error)")
        }

        return OMIDSDK.sharedInstance.isActive
    }

    func createAdSession() -> OMIDAdSession? {
        let partnerName = Bundle.main.bundleIdentifier ?? "com.omid-partner"
        let partnerVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        guard let partner = OMIDPartner(name: partnerName, versionString: partnerVersion ?? "1.0")
            else {
                fatalError("Unable to initialize OMID partner")
        }

        guard let webView = webView else {
            fatalError("WebView is not initialized")
        }

        do {
            //Create web view context
            let context = try OMIDAdSessionContext(partner: partner, webView: webView, customReferenceIdentifier: nil)

            //Create ad session configuration
            let configuration = try OMIDAdSessionConfiguration(impressionOwner: OMIDOwner.init(rawValue: 1), videoEventsOwner: OMIDOwner.init(rawValue: 2))

            //Create ad session
            let session = try OMIDAdSession(configuration: configuration, adSessionContext: context)

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

    func injectOMID(intoHTML HTML: String) -> String {
        do {
            guard let url = Bundle.main.url(forResource: "omsdk-v1", withExtension: "js") else {
                    fatalError("Unable to inject OMID JS into ad creative")
            }

            let OMIDJSService = try String(contentsOf: url)

            let creativeWithOMID = try OMIDScriptInjector.injectScriptContent(OMIDJSService,
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
        print(webViewLoadingStatusHandler)

        if let webView = webView {
            adView.addSubview(webView)
            adView.sendSubview(toBack: webView)
            webView.loadHTMLString(creative, baseURL: URL(string: "http://localhost:8000"))
        }
    }

    func displayAd() {
        guard adContainerView.isHidden else {
            return
        }

        NSLog("Ad container will appear.")
        willDisplayAd()

        statusLabel.isHidden = true
        adContainerView.isHidden = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.adContainerView.alpha = 1.0
        }) { (completed) in
            self.statusLabel.text = ""
        }

        if isPrerendering {
            startViewabilityMeasurement()
        } else {
            // Temporary workaround for https://github.com/InteractiveAdvertisingBureau/Open-Measurement-SDKiOS/issues/21
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                self.startViewabilityMeasurement()
            }
        }
    }

    func registerImpression() {
        //Fire ad sever impression trackers here to minimize discrepancies
        startViewabilityMeasurement()
        NSLog("Starting measurement session.")
    }
}

// MARK: - WKScriptMessageHandler
extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == webViewHandlerName,
            let body = message.body as? String,
            body == webViewDidFinishRenderingMessage
            else {
                return
        }

        NSLog("WebView has finished rendering")
        if (isPrerendering) {
            displayAd()
        }
    }
}

