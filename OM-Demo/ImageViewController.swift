//
//  ImageViewController.swift
//  OM-Demo
//
//  Created by Nathanael Hardy on 4/17/18.
//

import UIKit
import OMSDK_Demoapp

class ImageViewController: BaseAdUnitViewController {
    
    @IBOutlet weak var imageView: UIImageView!

    override var creativeURL: URL {
        return URL(string: Constants.staticImageAdURL)!
    }
    
    override func didFinishFetchingCreative(_ fileURL: URL) {
        NSLog("Did finish fetching creative.")
        imageView.image = UIImage(contentsOfFile: fileURL.path)
        presentAd()
    }

    override func destroyAd() {
        imageView.image = nil
    }

    override func createAdSessionContext(withPartner partner: OMIDDemoappPartner) -> OMIDDemoappAdSessionContext {
        //These values should be parsed from the ad response
        //For example:
        //[
        //  {
        //      "vendorKey": "iabtechlab.com-omid",
        //      "javascriptResourceUrl": "https://server.com/creative/omid-validation-verification-script-v1.js",
        //      "verificationParameters": "parameterstring"
        //  },
        //]

        //Using validation verification script as an example
        let urlToMeasurementScript = Constants.verificationScriptURL
        //Vendor key
        let vendorKey = Constants.vendorKey
        //Verification Parameters. This is just an arbitary string, however with validation verification script, the value that is passed here will be used as a remote URL for tracking events
        let parameters = Constants.verificationParameters

        //Create verification resource using the values provided in the ad response
        guard let verificationResource = createVerificationScriptResource(vendorKey: vendorKey,
                                                                          verificationScriptURL: urlToMeasurementScript.absoluteString,
                                                                          parameters: parameters)
            else {
                fatalError("Unable to instantiate session context: verification resource cannot be nil")
        }

        //Create native ad session context
        do {
            return try OMIDDemoappAdSessionContext(partner: partner, script: omidJSService, resources: [verificationResource], contentUrl: nil, customReferenceIdentifier: nil)
        } catch {
            fatalError("Unable to instantiate session context: \(error)")
        }
    }

    override func createAdSessionConfiguration() -> OMIDDemoappAdSessionConfiguration {
        //Create ad session configuration
        do {
            return try OMIDDemoappAdSessionConfiguration(creativeType: .nativeDisplay, impressionType: .viewable, impressionOwner: .nativeOwner, mediaEventsOwner: .noneOwner, isolateVerificationScripts: true)
        } catch {
            fatalError("Unable to create ad session configuration: \(error)")
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
