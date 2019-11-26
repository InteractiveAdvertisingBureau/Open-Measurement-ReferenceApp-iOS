//
//  Constants.swift
//  OM-Demo
//
//  Created by Nathanael Hardy on 4/12/18.
//

import Foundation

struct Constants {
    static let vendorKey = "iabtechlab.com-omid"
    
    // TODO: Update hosted creative with updated omid-validation-verification-script-v1.3
    static let HTMLAdURL = "https://s3-us-west-2.amazonaws.com/omsdk-files/demo/creative/banner.html"
    
    static let videoAdURL = "https://s3-us-west-2.amazonaws.com/omsdk-files/demo/creative/MANIA.mp4"
    static let staticImageAdURL = "https://s3-us-west-2.amazonaws.com/omsdk-files/demo/creative/mania.jpeg"
    
    static var audioAdURL: URL {
        let url = Bundle.main.url(forResource: "sampleAudioAd", withExtension: "mp3")!
        return url
    }
        
    //TODO: remove verification script as a resource
    
    static var verificationScriptURL: URL {
        let url = Bundle.main.url(forResource: "omid-validation-verification-script-v1", withExtension: "js")!
        return url
    }

    
    static let verificationParameters = ""
}
