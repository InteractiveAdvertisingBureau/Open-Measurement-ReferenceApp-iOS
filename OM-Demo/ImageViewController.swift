//
//  ImageViewController.swift
//  OM-Demo
//
//  Created by Nathanael Hardy on 4/17/18.
//

import UIKit
import AVKit
import OMSDK_IAB

class ImageViewController: OMDemoViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var omidAdEvents: OMIDIABAdEvents?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Native Image"
        createImageView()
        displayAd()
    }
    
    override func displayAd() {
        super.displayAd()
        startViewabilityMeasurement()
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
            guard let urlToMeasurementResource = URL(string: Constants.ServerResource.verificationScriptURL.rawValue) else {
                showErrorMessage(message: "Unable to instantiate verification resource url")
                return nil
            }
            
            //Create verification resource from vendor
            let parameters = Constants.ServerResource.verificationParameters.rawValue

            guard let verificationResource = OMIDIABVerificationScriptResource(url: urlToMeasurementResource, vendorKey: Constants.vendorKey, parameters: parameters) else {
                showErrorMessage(message: "Unable to instantiate verification resource")
                return nil
            }
            
            //Load omid service asset
            guard let omidServiceUrl = URL(string: Constants.ServerResource.omsdkjs.rawValue) else {
                showErrorMessage(message: "Unable to access resource with name \(Constants.ServerResource.omsdkjs)")
                return nil
            }
            
            let OMIDJSService = try String(contentsOf: omidServiceUrl)
            
            //Create native image context
            let context = try OMIDIABAdSessionContext(partner: partner, script: OMIDJSService, resources: [verificationResource], customReferenceIdentifier: nil)
            
            //Create ad session configuration
            let configuration = try OMIDIABAdSessionConfiguration(impressionOwner: OMIDOwner.nativeOwner, videoEventsOwner: OMIDOwner.noneOwner, isolateVerificationScripts: false)
            
            //Create ad session
            let session = try OMIDIABAdSession(configuration: configuration, adSessionContext: context)
            
            //Provide main ad view for measurement
            session.mainAdView = imageView
            
            //Register any views that are intentionally overlaying the main view
            session.addFriendlyObstruction(closeButton)
            
            //Instantiate image and ad events
            omidAdEvents = try OMIDIABAdEvents(adSession: session)
            
            return session
        } catch {
            showErrorMessage(message: "Unable to instantiate ad session: \(error)")
        }
        return nil
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
        guard let filePath = URL(string: Constants.ServerResource.imageAd.rawValue) else {
            showErrorMessage(message: "Unable to instantiate image URL")
            return
        }
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: filePath)
            DispatchQueue.main.async {
                if let imageData = data {
                    self.imageView.image = UIImage(data: imageData)
                    self.recordImpression()
                } else {
                    self.showErrorMessage(message: "Failed to download image from: \(filePath)")
                    return
                }
            }
        }
    }
}
