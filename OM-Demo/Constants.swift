//
//  Constants.swift
//  OM-Demo
//
//  Created by Nathanael Hardy on 4/12/18.
//

import Foundation

struct Constants {
    static let vendorKey = "iabtechlab.com-omid"
    
    static let HTMLAdURL = "https://omsdk-files.s3-us-west-2.amazonaws.com/ra_1.3/testCreativeScript.html"
    
    static let videoAdURL = "https://omsdk-files.s3-us-west-2.amazonaws.com/ra_1.3/IABTL_VAST_Intro_30s.mp4"
    
    static let staticImageAdURL = "https://s3-us-west-2.amazonaws.com/omsdk-files/demo/creative/mania.jpeg"
    
    static var audioAdURL = "https://omsdk-files.s3-us-west-2.amazonaws.com/ra_1.3/IABTechLab_audio_test_file.mp3"
   
    static var verificationScriptURL = "https://s3-us-west-2.amazonaws.com/omsdk-files/compliance-js/omid-validation-verification-script-v1.js"
    
    static let verificationParameters = ""
    
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
}
