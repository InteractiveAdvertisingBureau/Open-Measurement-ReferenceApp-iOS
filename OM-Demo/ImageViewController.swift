//
//  ImageViewController.swift
//  OM-Demo
//
//  Created by Nathanael Hardy on 4/17/18.
//  Copyright © 2018 Open Measurement Working Group. All rights reserved.
//

import UIKit
import AVKit
import OMSDK_IAB

class ImageViewController: WebViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var omidAdEvents: OMIDIABAdEvents?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Native Image"
        createImageView()
        displayAd()
 
    }
    
    override func setupAdSession() {
        adSession = createAdSession()
    }
    
    override func createAdSession() -> OMIDIABAdSession? {
        let partnerName = Bundle.main.bundleIdentifier ?? "com.omid-partner"
        let partnerVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        guard let partner = OMIDIABPartner(name: partnerName, versionString: partnerVersion ?? "1.0")
            else {
                fatalError("Unable to initialize OMID partner")
        }
        
        guard let imageView = imageView else {
            fatalError("Image view is not initialized")
        }
        
        do {
            //Url for verification resource
            guard let urlToMeasurementResource = URL(string: Constants.ServerResource.verificationValidationScript.rawValue) else {
                fatalError("Unable to instantiate url")
            }
            
            //Create verification resource from vendor
            let urlString = Constants.ServerResource.dummmyVerificationServer.rawValue

            guard let verificationResource = OMIDIABVerificationScriptResource(url: urlToMeasurementResource, vendorKey: "dummyVendor", parameters: urlString) else {
                fatalError("Unable to instantiate verification resource")
            }
            
            //Load omid service asset
            guard let omidServiceUrl = URL(string: Constants.ServerResource.omsdkjs.rawValue) else {
                fatalError("Unable to access resource with name \(Constants.ServerResource.omsdkjs)")
            }
            
            let OMIDJSService = try String(contentsOf: omidServiceUrl)
            
            //Create native video context
            let context = try OMIDIABAdSessionContext(partner: partner, script: OMIDJSService, resources: [verificationResource], customReferenceIdentifier: nil)
            
            //Create ad session configuration
            let configuration = try OMIDIABAdSessionConfiguration(impressionOwner: OMIDOwner.nativeOwner, videoEventsOwner: OMIDOwner.nativeOwner, isolateVerificationScripts: false)
            
            //Create ad session
            let session = try OMIDIABAdSession(configuration: configuration, adSessionContext: context)
            
            //Provide main ad view for measurement
            session.mainAdView = imageView
            
            //Register any views that are intentionally overlaying the main view
            session.addFriendlyObstruction(closeButton)
            
            //Instantiate video and ad events
            omidAdEvents = try OMIDIABAdEvents(adSession: session)
            
            return session
        } catch {
            fatalError("Unable to instantiate ad session: \(error)")
        }
        return nil
    }
    
    override func startViewabilityMeasurement() {
        guard prepareOMID() else {
            fatalError("OMID is not active")
        }

        destroyAd()
        createImageView()
        setupAdSession()
        NSLog("Starting measurement session now")
    }
    
    func recordImpression() {
        do {
            try omidAdEvents?.impressionOccurred()
        } catch let error as NSError {
            fatalError("OMID impression error: \(error.localizedDescription)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension ImageViewController {
    func createImageView() {
        guard let filePath = URL(string: Constants.ServerResource.imageAd.rawValue) else { fatalError("Failed to find image url") }
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: filePath)
            DispatchQueue.main.async {
                if let imageData = data {
                    self.imageView.image = UIImage(data: imageData)
                    self.recordImpression()
                } else {
                    fatalError("Failed to download image")
                }
            }
        }
    }
}
