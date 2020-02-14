//
//  BaseAdUnitViewController.swift
//  OM-Demo
//
//  Created by Nathanael Hardy on 4/20/18.
//

import UIKit
import WebKit
import MediaPlayer
import OMSDK_Demoapp

class BaseAdUnitViewController: UIViewController {
    fileprivate var isDisplayingErrorMessage = false
    fileprivate var creativeDownloadTask: URLSessionDownloadTask?
    var displayInProgress = false

    @IBOutlet var adContainerView: UIView!
    @IBOutlet var adView: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var closeButton: UIButton!

    var adUnit: AdUnit?
    
    var adSession: OMIDDemoappAdSession?
    var adEvents: OMIDDemoappAdEvents?
    
    var creativeURL: URL {
        fatalError("Not implemented")
    }

    var omidJSService: String {
        //Load OMID JS service contents
        let omidServiceUrl = Bundle.main.url(forResource: "omsdk-v1", withExtension: "js")!
        return try! String(contentsOf: omidServiceUrl)
    }
    
    var isPrerendering: Bool {
        return Settings.shared.isPrerendering
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adContainerView.isHidden = true
        adContainerView.alpha = 0.0
        statusLabel.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.requestAd()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismissAd()
    }

    /**
     Downloads creative contents from `creativeURL` into a file and calls didFinishFetchingCreative() with the URL of that file
     */
    @IBAction func requestAd() {
        statusLabel.isHidden = false
        statusLabel.text = "Requesting an ad.."

        fetchCreative(creativeURL) { (fileURL) in
            self.didFinishFetchingCreative(fileURL)
        }
    }

    /**
     Dismisses ad container and calls finishMeasurement()
     */
    @IBAction func dismissAd() {
        guard !adContainerView.isHidden else {
            return
        }

        NSLog("Ad Container is about to be dismissed")
        UIView.animate(withDuration: 0.5, animations: {
            self.adContainerView.alpha = 0.0
        }) { (completed) in
            NSLog("Ad Container is hidden")
            self.didDismissAd()
        }
    }
    
    /**
     Asynchronously loads creative from a remote URL or local file URL
     
     - Parameters:
     - creativeURL: URL to creative (either remote or local)
     - completionHandler: completion handler that is called when creative loads successfully
     - content: contents of the creative
     */
    func fetchCreative(_ creativeURL: URL!, _ completionHandler: @escaping (_ content: String) -> ()) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Fetching..."
        }
        NSLog("Fetching creative.")
        DispatchQueue.global().async {
            if creativeURL.isFileURL {
                let content = try! String(contentsOf: creativeURL)
                DispatchQueue.main.async {
                    NSLog("Did finish fetching creative.")
                    completionHandler(content)
                }
            } else {
                NSLog("Loading creative from remote URL.")
                self.creativeDownloadTask = URLSession.shared.downloadTask(with: creativeURL) {
                    [weak self] (fileURL, response, error) in
                    guard let fileURL = fileURL else {
                        self?.showErrorMessage(message: "Unable to fetch creative from remote URL: \(creativeURL!)")
                        return
                    }
                    
                    print(response ?? "no response")
                    print(error ?? "no error")
                    NSLog("Finished loading creative from remote URL.")
                    self?.fetchCreative(fileURL, completionHandler)
                }
                self.creativeDownloadTask?.resume()
            }
        }
    }

    /**
     Is called when creative has finished downloading.
     Subclasses have to implement this method.

     - Parameters:
     - fileURL: a file URL where creative content is located
     */
    func didFinishFetchingCreative(_ fileURL: URL) {
        fatalError("Not implemented")
    }

    /**
     Releases any resources that the ad may still be using after dismissal.
     Subclasses have to implement this method.
    */
    func destroyAd() {
        fatalError("Not implemented")
    }


    /**
     Displays the ad container.
     Subclasses should call this method when ad view is added to the ad container and is ready for display.
     */
    func presentAd() {
        guard adContainerView.isHidden else {
            return
        }

        NSLog("Ad container will appear.")
        willPresentAd()

        statusLabel.isHidden = true
        adContainerView.isHidden = false

        UIView.animate(withDuration: 0.5, animations: {
            self.adContainerView.alpha = 1.0
        }) { (completed) in
            self.statusLabel.text = ""
        }
    }

    /**
     This method is called when the ad begins to display (begin-to-render impression event).

     Starts measurement session.
     */
    func willPresentAd() {
        //This is the point where other impression trackers (ad server impression, etc) should fire

        startMeasurement()
    }

    /**
     This method is called when the ad is dismissed.

     Finishes measurement session and destroys the ad
     */
    func didDismissAd() {
        adContainerView.isHidden = true

        //Finish measurement
        NSLog("Ending measurement session now")
        finishMeasurement()

        //Destroy the ad
        destroyAd()
    }

    /**
     If SDK is active, creates new ad session and a new instance of ad events,
     then starts the ad session and records impression event.
     This method is called when the ad begings to display.
     */
    func startMeasurement() {
        //Activate the SDK if not already active
        guard activateOMSDK() else {
            fatalError("OMID is not active")
        }

        //Create new ad session
        adSession = createAdSession()

        //Create ad events if native impression is used
        //(native impression registration can be used when rendering in a WebView as well)
        do {
            guard let adSession = adSession else {
                fatalError("Ad session cannot be nil")
            }

            adEvents = try OMIDDemoappAdEvents(adSession: adSession)
            setupAdditionalAdEvents(adSession: adSession)

        } catch {
            fatalError("Unable to instantiate ad events: \(error)")
        }

        NSLog("Starting measurement session.")
        //Start measuring
        adSession?.start()
        
        //Fire loaded event
        adLoaded()

        //Record OMID native impression
        do {
            NSLog("Firing OMID impression event.")
            try adEvents?.impressionOccurred()
        } catch let error as NSError {
            fatalError("OMID impression error: \(error.localizedDescription)")
        }
    }
    
    /**
     Calls AdEvents loaded.
     Subclasses have to implement this method.
    */
    func adLoaded() {
        fatalError("Not implemented")
    }
    
    /**
     Finishes the ad session. This method is called when the ad is dismissed.
     */
    func finishMeasurement() {
        //Finish ad session
        adSession?.finish()
    }

    private func activateOMSDK() -> Bool {
        if OMIDDemoappSDK.shared.isActive {
            return true
        }

        //Activate the SDK
        OMIDDemoappSDK.shared.activate()
       
        return OMIDDemoappSDK.shared.isActive

    }

    private func createAdSession() -> OMIDDemoappAdSession {
        //Partner name has to be unique to your integration
        let partnerName = "Demoapp"
        let partnerVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        guard let partner = OMIDDemoappPartner(name: partnerName, versionString: partnerVersion ?? "1.0")
            else {
                fatalError("Unable to initialize OMID partner")
        }

        //Obtain ad session context. The context may be different depending on the type of the ad unit.
        let context = createAdSessionContext(withPartner: partner)

        //Obtain ad session configuration. Configuration may be different depending on the type of the ad unit.
        let configuration = createAdSessionConfiguration()

        do {
            //Create ad session
            let session = try OMIDDemoappAdSession(configuration: configuration, adSessionContext: context)
            
            //Only add adView if not nativeAudio adUnit
            if let adUnit = adUnit, adUnit == .nativeAudio {
                return session
            }
            
            //Provide main ad view for measurement
            guard let adView = adView else {
                fatalError("Ad View is not initialized")
            }
            session.mainAdView = adView

            //Register any views that are intentionally overlaying the main view
            //In this example the close button is overlaying the ad view and is considered a friendly obstruction
            session.addFriendlyObstruction(closeButton)

            return session
        } catch {
            fatalError("Unable to instantiate ad session: \(error)")
        }

    }

    /**
     This method is called right after OMIDMediaEvents has been set up
     Subclasses can use this method to create `OMIDMediaEvents`.
     Default implementation does nothing.
     */
    func setupAdditionalAdEvents(adSession: OMIDDemoappAdSession) {
        return
    }


    /**
     Creates ad session context.
     Subclasses have to implement this method.

     - Parameters:
     - partner: instance of `OMIDPartner` to be used in the ad session context

     - Returns: an instance of `OMIDAdSessionContext` that was created

     */
    func createAdSessionContext(withPartner partner: OMIDDemoappPartner) -> OMIDDemoappAdSessionContext {
        fatalError("Not implemented")
    }

    /**
     Creates ad session configuration.
     Subclasses have to implement this method.

     - Returns: an instance of `OMIDAdSessionConfiguration` that was created

     */
    func createAdSessionConfiguration() -> OMIDDemoappAdSessionConfiguration {
        fatalError("Not implemented")
    }
    
    func createVerificationScriptResource(vendorKey: String?, verificationScriptURL: String, parameters: String?) -> OMIDDemoappVerificationScriptResource? {
        guard let URL = URL(string: verificationScriptURL) else {
            fatalError("Unable to parse Verification Script URL")
        }
        
        if let vendorKey = vendorKey,
            let parameters = parameters,
            vendorKey.count > 0 && parameters.count > 0 {
                return OMIDDemoappVerificationScriptResource(url: URL,
                                                               vendorKey: vendorKey,
                                                               parameters: parameters)
        } else {
            return OMIDDemoappVerificationScriptResource(url: URL)
        }
    }
}

// MARK: - Helpers
extension BaseAdUnitViewController {
    /**
     Asynchronously loads creative from a remote URL

     - Parameters:
     - remoteURL: URL to creative
     - completionHandler: completion handler that is called when creative loads successfully
     - fileURL: contents of the creative
     */
    private func fetchCreative(_ remoteURL: URL, _ completionHandler: @escaping (_ fileURL: URL) -> ()) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Fetching..."
        }

        NSLog("Fetching creative from '\(remoteURL)'.")
        self.creativeDownloadTask = URLSession.shared.downloadTask(with: remoteURL) {
            [weak self] (fileURL, response, error) in
            guard let fileURL = fileURL else {
                DispatchQueue.main.async {
                    self?.showErrorMessage(message: "Unable to fetch creative from remote URL: \(remoteURL)")
                }
                return
            }

            DispatchQueue.main.async {
                completionHandler(fileURL)
            }
        }

        self.creativeDownloadTask?.resume()
    }

    /**
     Display error messages to the user using UIAlertController
     */
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
