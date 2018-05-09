//
//  ImageViewController.swift
//  OM-Demo
//
//  Created by Nathanael Hardy on 4/17/18.
//

import UIKit
import AVKit
import OMSDK_Pandora

class ImageViewController: BaseAdUnitViewController {
    @IBOutlet weak var imageView: UIImageView!

    override var creativeURL: URL {
        return URL(string: Constants.ServerResource.imageAd.rawValue)!
    }
    
    override func didFinishFetchingCreative(_ fileURL: URL) {
        NSLog("Did finish fetching creative.")
        imageView.image = UIImage(contentsOfFile: fileURL.path)
        presentAd()
    }

    override func createAdSessionContext(withPartner partner: OMIDPandoraPartner) -> OMIDPandoraAdSessionContext {
        //These values should be parsed from the ad response
        //For example:
        //[
        //  {
        //      "vendorKey": "dummyVendor",
        //      "javascriptResourceUrl": "http://localhost:8787/creative/omid-validation-verification-script-v1.js",
        //      "verificationParameters": "http://dummy-domain/m?"
        //  },
        //]

        //Usign validation verification script as an example
        let urlToMeasurementScript = URL(string: "http://localhost:8787/creative/omid-validation-verification-script-v1.js")!
        //Vendor key
        let vendorKey = "dummyVendor"
        //Verification Parameters. This is just an arbitary string, however with validation verification script, the value that is passed here will be used as a remote URL for tracking events
        let parameters = "http://dummy-domain/m?"

        //Create verification resource for <AdVerification> from above
        guard let verificationResource = OMIDPandoraVerificationScriptResource(url: urlToMeasurementScript, vendorKey: vendorKey, parameters: parameters) else {
            fatalError("Unable to instantiate session context: verification resource cannot be nil")
        }

        //Create native ad session context
        do {
            return try OMIDPandoraAdSessionContext(partner: partner, script: omidJSService, resources: [verificationResource], customReferenceIdentifier: nil)
        } catch {
            fatalError("Unable to instantiate session context: \(error)")
        }
    }

    override func createAdSessionConfiguration() -> OMIDPandoraAdSessionConfiguration {
        //Create ad session configuration
        do {
            return try OMIDPandoraAdSessionConfiguration(impressionOwner: .nativeOwner,
                                                     videoEventsOwner: .noneOwner,
                                                     isolateVerificationScripts: false)
        } catch {
            fatalError("Unable to create ad session configuration: \(error)")
        }
    }

    override func destroyAd() {
        imageView.image = nil
    }
}
