//
//  Utility.swift
//  OM-Demo
//
//  Created by Nathanael Hardy on 4/12/18.
//  Copyright © 2018 Open Measurement Working Group. All rights reserved.
//

import Foundation

struct Constants {
    static let OMIDAPIVersion = "{\"v\":\"1.0.1\"}"
    static let webViewHandlerName = "loadingStatusHandler"
    static let webViewDidFinishRenderingMessage = "didFinishRendering"
    
    // JavaScript to handle web view finish rendering event
    static let webViewLoadingStatusHandler = """
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
    
    /**
     URLs used for Java Script resources and creative resources.  Expand upon this enum for personal creative testing.
     */
    enum ServerResource: String {
        case bannerAd = "http://localhost:8787/creative/banner.html"
        case videoAd = "http://localhost:8787/creative/MANIA.mp4"
        case imageAd = "http://localhost:8787/creative/MANIA.jpeg"
        case omsdkjs = "http://localhost:8787/creative/omsdk-v1.js"
        case sessionClient = "http://localhost:8787/creative/omid-session-client-v1.js"
        case verificationValidationScript = "http://localhost:8787/creative/omid-validation-verification-script-v1.js"
        case dummmyVerificationServer = "http://localhost:8787/m?"
        case baseURL = "http://localhost:8787/"
    }
}
