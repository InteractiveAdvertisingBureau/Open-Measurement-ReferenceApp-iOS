//
//  OMDemoViewController.swift
//  OM-Demo
//
//  Created by Nathanael Hardy on 4/20/18.
//

import UIKit
import WebKit
import MediaPlayer
import OMSDK_IAB

class OMDemoViewController: UIViewController {
    @IBOutlet var adContainerView: UIView!
    @IBOutlet var adView: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var closeButton: UIButton!
    
    var adSession: OMIDIABAdSession?
    var displayInProgress = false
    var isDisplayingErrorMessage = false
    
    func willDisplayAd() {}
    func willDismissAd() {}
    func destroyAd() {}
    func createAdSession() -> OMIDIABAdSession? { fatalError("Not implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adContainerView.isHidden = true
        adContainerView.alpha = 0.0
        statusLabel.isHidden = true
    }
    
    func setupAdSession() {
        adSession = createAdSession()
    }
    
    func startViewabilityMeasurement() {
        guard prepareOMID() else {
            fatalError("OMID is not active")
        }
        
        NSLog("Starting measurement session now")
        setupAdSession()
        adSession?.start()
    }
    
    func prepareOMID() -> Bool {
        if OMIDIABSDK.shared.isActive {
            return true
        }
        guard OMIDIABSDK.isCompatible(withOMIDAPIVersion: Constants.OMIDAPIVersion) else {
            fatalError("OMID SDK is not compatible with OMID API version")
        }
        
        do {
            try OMIDIABSDK.shared.activate(withOMIDAPIVersion: Constants.OMIDAPIVersion)
        } catch {
            fatalError("Unable to activate OMID SDK: \(error)")
        }
        
        return OMIDIABSDK.shared.isActive
    }
    
    func finishViewabilityMeasurement() {
        NSLog("Ending measurement session now")
        self.adSession?.finish()
        self.destroyAd()
    }
    
    func registerImpression() {
        //Fire ad sever impression trackers here to minimize discrepancies
        startViewabilityMeasurement()
        NSLog("Starting measurement session.")
    }
    
}

// MARK: - Outlet Handlers
extension OMDemoViewController {
    
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
            self.adContainerView.isHidden = true
            self.displayInProgress = false
        }
    }
    
    /**
     Sets up ad container view
     */
    @IBAction func displayAd() {
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
    }
}

// MARK: - Error Handling
extension OMDemoViewController {
    func showErrorMessage(message: String) {
        if isDisplayingErrorMessage == false {
            isDisplayingErrorMessage = true
            let alert = UIAlertController(title: "An Error Was Encountered", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Exit", style: .default, handler: { action in
                switch action.style{
                case .default:
                    self.navigationController?.popToRootViewController(animated: true)
                    self.isDisplayingErrorMessage = false
                default:
                    break
                }}))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

