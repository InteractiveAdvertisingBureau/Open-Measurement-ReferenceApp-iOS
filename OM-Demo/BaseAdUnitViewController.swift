//
//  BaseAdUnitViewController.swift
//  OM-Demo
//
//  Created by Nathanael Hardy on 4/20/18.
//

import UIKit
import WebKit
import MediaPlayer
import OMSDK_Demobuild

class BaseAdUnitViewController: UIViewController {
    fileprivate var isDisplayingErrorMessage = false
    fileprivate var creativeDownloadTask: URLSessionDownloadTask?

    @IBOutlet var adContainerView: UIView!
    @IBOutlet var adView: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var closeButton: UIButton!

    var adSession: OMIDDemobuildAdSession?
    var adEvents: OMIDDemobuildAdEvents?
    
    var creativeURL: URL {
        fatalError("Not implemented")
    }

    var omidJSService: String {
        //Load OMID JS service contents
        let omidServiceUrl = Bundle.main.url(forResource: "omsdk-v1", withExtension: "js")!
        return try! String(contentsOf: omidServiceUrl)
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
            NSLog("Did finish fetching creative.")
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

        NSLog("Starting measurement session.")
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

            adEvents = try OMIDDemobuildAdEvents(adSession: adSession)
            setupAdditionalAdEvents(adSession: adSession)

        } catch {
            fatalError("Unable to instantiate ad events: \(error)")
        }

        NSLog("Starting measurement session.")
        //Start measuring
        adSession?.start()

        //Record OMID native impression
        do {
            NSLog("Firing OMID impression event.")
            try adEvents?.impressionOccurred()
        } catch let error as NSError {
            fatalError("OMID impression error: \(error.localizedDescription)")
        }
    }

    /**
     Finishes the ad session. This method is called when the ad is dismissed.
     */
    func finishMeasurement() {
        //Finish ad session
        adSession?.finish()
    }

    private func activateOMSDK() -> Bool {
        if OMIDDemobuildSDK.shared.isActive {
            return true
        }

        //The version of the OMID JS service that will be used
        let APIVersion = "{\"v\":\"1.1.1\"}"

        //Check if the version of JS API is compatible with the version of native SDK
        guard OMIDDemobuildSDK.isCompatible(withOMIDAPIVersion: APIVersion) else {
            fatalError("OMID SDK is not compatible with OMID API version")
        }

        //Activate the SDK
        do {
            try OMIDDemobuildSDK.shared.activate(withOMIDAPIVersion: APIVersion)
        } catch {
            fatalError("Unable to activate OMID SDK: \(error)")
        }

        return OMIDDemobuildSDK.shared.isActive

    }

    private func createAdSession() -> OMIDDemobuildAdSession {
        //Partner name has to be unique to your integration
        let partnerName = "Demobuild"
        let partnerVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        guard let partner = OMIDDemobuildPartner(name: partnerName, versionString: partnerVersion ?? "1.0")
            else {
                fatalError("Unable to initialize OMID partner")
        }

        //Obtain ad session context. The context may be different depending on the type of the ad unit.
        let context = createAdSessionContext(withPartner: partner)

        //Obtain ad session configuration. Configuration may be different depending on the type of the ad unit.
        let configuration = createAdSessionConfiguration()

        do {
            //Create ad session
            let session = try OMIDDemobuildAdSession(configuration: configuration, adSessionContext: context)

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
     This method is called right after OMIDDemobuildVideoEvents has been set up
     Subclasses can use this method to create `OMIDDemobuildVideoEvents`.
     Default implementation does nothing.
     */
    func setupAdditionalAdEvents(adSession: OMIDDemobuildAdSession) {
        return
    }


    /**
     Creates ad session context.
     Subclasses have to implement this method.

     - Parameters:
     - partner: instance of `OMIDDemobuildPartner` to be used in the ad session context

     - Returns: an instance of `OMIDDemobuildAdSessionContext` that was created

     */
    func createAdSessionContext(withPartner partner: OMIDDemobuildPartner) -> OMIDDemobuildAdSessionContext {
        fatalError("Not implemented")
    }

    /**
     Creates ad session configuration.
     Subclasses have to implement this method.

     - Returns: an instance of `OMIDDemobuildAdSessionConfiguration` that was created

     */
    func createAdSessionConfiguration() -> OMIDDemobuildAdSessionConfiguration {
        fatalError("Not implemented")
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

            print(response ?? "no response")
            print(error ?? "no error")

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

