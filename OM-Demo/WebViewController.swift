//
//  WebViewController.swift
//  OM-Demo
//
//  Created by Alex Chugunov on 9/17/17.
//

import UIKit
import WebKit
import MediaPlayer
import OMSDK_Demoapp

class WebViewController: BaseAdUnitViewController {
    var webView: WKWebView?
    var webViewInitialNavigation: WKNavigation?
    
    override var creativeURL: URL {
        //URL to the ad creative
        return URL(string: Constants.HTMLAdURL)!
    }

    override func didFinishFetchingCreative(_ fileURL: URL) {
        do {
            let HTML = try String(contentsOf: fileURL)
            NSLog("Did finish fetching creative.")

            //Create webview
            webView = WKWebView(frame: adView.bounds)
            webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            webView?.navigationDelegate = self
            
            let loadingStatusScript = WKUserScript(source: Constants.webViewLoadingStatusHandler,
                                                   injectionTime: .atDocumentStart,
                                                   forMainFrameOnly: true)
            webView?.configuration.userContentController.addUserScript(loadingStatusScript)
            webView?.configuration.userContentController.add(self, name: Constants.webViewHandlerName)

            //Begin loading HTML in the webview
            Settings.shared.isPrerendering ? displayAfterRendering(withHTML: HTML) : displayImmediately(withHTML: HTML)
        } catch {
            self.showErrorMessage(message: "Unable to load creative: \(error)")
        }
    }

    override func destroyAd() {
        guard let webView = webView else {
            return
        }

        // Delay destruction of the webview by at least 1 second, otherwise sessionFinish event will not have enough time to execute.
        // Temporary workaround for https://github.com/InteractiveAdvertisingBureau/Open-Measurement-SDKiOS/issues/22
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            webView.navigationDelegate = nil
            webView.scrollView.isScrollEnabled = false
            webView.stopLoading()

            webView.removeFromSuperview()
            self.webView = nil
            NSLog("WebView was destroyed")
        }
    }

    override func createAdSessionConfiguration() -> OMIDDemoappAdSessionConfiguration {
        do {
            return try OMIDDemoappAdSessionConfiguration(creativeType: .htmlDisplay,
                                                  impressionType: .beginToRender,
                                                  impressionOwner: .nativeOwner,
                                                  mediaEventsOwner: .noneOwner,
                                                  isolateVerificationScripts: true)
        } catch {
            fatalError("Unable to create ad session configuration: \(error)")
        }
    }

    override func createAdSessionContext(withPartner partner: OMIDDemoappPartner) -> OMIDDemoappAdSessionContext {
        guard let webView = webView else {
            fatalError("Unable to create ad session context: webView is not initialized")
        }

        do {
            return try OMIDDemoappAdSessionContext(partner: partner, webView: webView, contentUrl: nil, customReferenceIdentifier: nil)
        } catch {
            fatalError("Unable to create ad session context: \(error)")
        }
    }
    
    override func adLoaded() {
        do {
            try adEvents?.loaded()
        } catch {
            fatalError("Unable to trigger loaded event: \(error)")
        }
    }
}

// MARK: - WKScriptMessageHandler
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if navigation === webViewInitialNavigation {
            NSLog("WebView did finish loading creative")

            //This is an equivalent of listening to DOMContentLoaded event in JS
            //OMID JS service is not guaranteed to handle any events prior to this point and you should avoid executing native impression event (registered in presentAd()) until DOM is loaded completely. If you're pre-rendering webviews, then waiting for window.onload event is also an option)

            //OMID JS service is now fully operational and it's safe to display the webview and register native impression
            
            if (!isPrerendering) {
                presentAd()
            }
        }
    }
}

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
            presentAd()
        }
    }
}


// MARK: - WebView lifecycle
extension WebViewController {
    func injectOMID(intoHTML HTML: String) -> String {
        do {
            let creativeWithOMID = try OMIDDemoappScriptInjector.injectScriptContent(omidJSService,
                                                                                     intoHTML:HTML)
            return creativeWithOMID
        } catch {
            fatalError("Unable to inject OMID JS into ad creative: \(error)")
        }
    }


    func loadAd(withHTML HTML: String) {
        guard let webView = webView else {
            showErrorMessage(message: "Failed to create webView")
            return
        }

        //Inject OMID JS service script into HTML creative
        //This is only necessary if OMID JS is not injected on the server side
        let creative = injectOMID(intoHTML: HTML)

        statusLabel.text = "Loading HTML..."

        // Adding the webview to the view hierarchy to allow rendering.
        // Ideally we don't want to display the webview until DOM is loaded.
        adView.addSubview(webView)
        adView.sendSubview(toBack: webView)

        // Start loading HTML, this will trigger webView rendering as well.
        // This implementation uses loadHTMLString() method to load HTML from string,
        // however using load() method here with a remote URL is also an option
        webViewInitialNavigation = webView.loadHTMLString(creative, baseURL: creativeURL.baseURL)
    }
}

// MARK: Prerendering
extension WebViewController {
    /**
     Displays ad container with the webview after rendering completes.
     */
    
    func displayAfterRendering(withHTML HTML: String) {
        guard !displayInProgress else {
            return
        }
        
        displayInProgress = true
        statusLabel.isHidden = false
        
        self.loadAd(withHTML: HTML)
    }
    
    /**
     Displays ad container with the webview before rendering starts.
     */
    
    func displayImmediately(withHTML HTML: String) {
        guard !displayInProgress else {
            return
        }
        
        displayInProgress = true
        statusLabel.isHidden = false
        presentAd()
        loadAd(withHTML: HTML)
    }
}

