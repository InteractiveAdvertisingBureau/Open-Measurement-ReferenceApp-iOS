//
//  Constants.swift
//  OM-Demo
//
//  Created by Nathanael Hardy on 4/12/18.
//

import Foundation

struct Constants {
    static let vendorKey = "iabtechlab.com-omid"
    
    static let HTMLAdURL = "https://s3-us-west-2.amazonaws.com/omsdk-files/demo/creative/banner.html"
    static let videoAdURL = "https://s3-us-west-2.amazonaws.com/omsdk-files/demo/creative/MANIA.mp4"
    static let staticImageAdURL = "https://s3-us-west-2.amazonaws.com/omsdk-files/demo/creative/mania.jpeg"
    
    // static let verificationScriptURL = "http://s3-us-west-2.amazonaws.com/omsdk-files/demo/creative/omid-validation-verification-script-v1.js"
    static var verificationScriptURL: URL {
        //Load OMID JS service contents
        let url = Bundle.main.url(forResource: "omid-validation-verification-script-v1", withExtension: "js")!
        return url
    }

    static let verificationParameters = ""
}
