//
//  VideoViewController.swift
//  OM-Demo
//
//  Created by Justin Hines on 11/6/17.
//

import UIKit
import AVKit
import OMSDK_IAB

enum Quartile {
    case Init
    case start
    case firstQuartile
    case midpoint
    case thirdQuartile
    case complete
}

class VideoViewController: OMDemoViewController {
    
    @IBOutlet var videoView: UIView?
    @IBOutlet var playButton: UIButton!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    var omidVideoEvents: OMIDIABVideoEvents?
    var omidAdEvents: OMIDIABAdEvents?
    
    var currentQuartile: Quartile = .Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Native VAST Video"
        
        hidePlayerControlls()
        
        displayAd()
    }
    
    override func displayAd() {
        super.displayAd()
        startViewabilityMeasurement()
        showPlayerControlls()
    }
    
    override func dismissAd() {
        super.dismissAd()
        hidePlayerControlls()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if player != nil {
            destroyVideoPlayer()
        }
    }
    
    override func createAdSession() -> OMIDIABAdSession? {
        let partnerName = Bundle.main.bundleIdentifier ?? "com.omid-partner"
        let partnerVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        guard let partner = OMIDIABPartner(name: partnerName, versionString: partnerVersion ?? "1.0")
            else {
                fatalError("Unable to initialize OMID partner")
        }
        
        guard let videoView = videoView else {
            fatalError("Video view is not initialized")
        }
        
        do {
            //Url for verification resource
            guard let urlToMeasurementResource = URL(string: Constants.ServerResource.verificationScriptURL.rawValue) else {
                fatalError("Unable to instantiate url")
            }
            
            //Create verification resource from vendor
            let parameters = Constants.ServerResource.verificationParameters.rawValue

            guard let verificationResource = OMIDIABVerificationScriptResource(url: urlToMeasurementResource, vendorKey: Constants.vendorKey, parameters: parameters) else {
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
            session.mainAdView = videoView
            
            //Register any views that are intentionally overlaying the main view
            session.addFriendlyObstruction(closeButton)
            
            //Instantiate video and ad events
            omidVideoEvents = try OMIDIABVideoEvents(adSession: session)
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

        createVideoPlayer()
        resetTimeLabels()
        addQuartileTrackingToVideoPlayer()
        setupAdSession()
        adSession?.start()
        recordImpression()
        play()
        attachPauseButtonImage()
        
        NSLog("Starting measurement session now")
    }
    
    func recordImpression() {
        do {
            try omidAdEvents?.impressionOccurred()
        } catch let error as NSError {
            fatalError("OMID impression error: \(error.localizedDescription)")
        }
    }
    
    override func destroyAd() {
        destroyVideoPlayer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension VideoViewController {
    var player: AVPlayer? {
        return playerLayer?.player
    }
    
    var playerLayer: AVPlayerLayer? {
        guard let videoView = videoView, let videoPlayerLayer = videoView.layer.sublayers?.first as? AVPlayerLayer else {
            return nil
        }
        return videoPlayerLayer
    }
    func createVideoPlayer() {
        guard let path = URL(string: Constants.ServerResource.videoAd.rawValue) else { return }
        
        let player = AVPlayer(url: path)
        player.volume = 1.0
        
        guard let videoView = videoView else {
            fatalError("VideoView is not initialized")
        }
        
        let videoPlayerLayer = AVPlayerLayer(player: player)
        videoPlayerLayer.bounds = videoView.bounds
        videoPlayerLayer.frame = videoView.bounds
        videoPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspect;
        
        videoView.layer.insertSublayer(videoPlayerLayer, at: 0)
    }
    
    func destroyVideoPlayer() {
        guard let videoPlayerLayer = playerLayer else { return }
        videoPlayerLayer.player = nil
        videoPlayerLayer.removeFromSuperlayer()
    }
    
    func addQuartileTrackingToVideoPlayer() {
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 10), queue: DispatchQueue.main) { (CMTime) -> Void in
            self.recordQuartileChange()
            self.updateTimeLabels()
            if self.player?.currentItem?.currentTime() == self.player?.currentItem?.duration {
                self.attachPlayButtonImage()
            }
        }
        
        currentQuartile = .Init
    }
}

// MARK: - Player Controlls

extension VideoViewController {
    @IBAction func tappedPlayingControl() {
        if player?.currentItem?.currentTime() == player?.currentItem?.duration {
            restartVideoAdSession()
            return
        }
        changePlayingControls()
    }
    
    func changePlayingControls() {
        if let player = player, player.rate == 0 {
            play()
            attachPauseButtonImage()
            omidVideoEvents?.resume()
        } else {
            pause()
            attachPlayButtonImage()
            omidVideoEvents?.pause()
        }
    }
    
    func attachPlayButtonImage() {
         playButton.setImage(UIImage(named: "playIcon"), for: .normal)
    }
    
    func attachPauseButtonImage() {
        playButton.setImage(UIImage(named: "pauseIcon"), for: .normal)
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func updateTimeLabels() {
        startTimeLabel.text = player?.currentTime().durationText ?? "0"
        endTimeLabel.text = player?.currentItem?.duration.durationText ?? "0"
    }
    
    func resetTimeLabels() {
        startTimeLabel.text = "0"
        endTimeLabel.text = "0"
    }
    
    @IBAction func restartVideoAdSession() {
        finishViewabilityMeasurement()
        startViewabilityMeasurement()
    }
    
    func hidePlayerControlls() {
        UIView.animate(withDuration: 0.5) {
            self.playButton.alpha = 0
            self.startTimeLabel.alpha = 0
            self.endTimeLabel.alpha = 0
            self.resetButton.alpha = 0
        }
    }
    
    func showPlayerControlls() {
        UIView.animate(withDuration: 0.5) {
            self.playButton.alpha = 1.0
            self.startTimeLabel.alpha = 1.0
            self.endTimeLabel.alpha = 1.0
            self.resetButton.alpha = 1.0
        }
    }
}

// MARK: - Quartile Changes

extension VideoViewController {
    func recordQuartileChange() {
        guard let currentItem = player?.currentItem else { return }
        let currentTime = CMTimeGetSeconds(currentItem.currentTime())
        let duration = CMTimeGetSeconds(currentItem.duration)
        let progressPercent = currentTime / duration
        
        switch currentQuartile {
        case .Init:
            if (progressPercent > 0) {
                guard let player = player else { break }
                omidVideoEvents?.start(withDuration: CGFloat(duration), videoPlayerVolume: CGFloat(player.volume))
                currentQuartile = .start
            }
        case .start:
            if (progressPercent > Double(1)/Double(4)) {
                omidVideoEvents?.firstQuartile()
                currentQuartile = .firstQuartile
            }
        case .firstQuartile:
            if (progressPercent > Double(1)/Double(2)) {
                omidVideoEvents?.midpoint()
                currentQuartile = .midpoint
            }
        case .midpoint:
            if (progressPercent > Double(3)/Double(4)) {
                omidVideoEvents?.thirdQuartile()
                currentQuartile = .thirdQuartile
            }
        case .thirdQuartile:
            if (progressPercent >= 1.0) {
                omidVideoEvents?.complete()
                currentQuartile = .complete
            }
        default:
            break
        }
    }
}

// MARK: - CMTime Extension

extension CMTime {
    var durationText: String {
        let totalSeconds = CMTimeGetSeconds(self)
        if !totalSeconds.isNaN {
            let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
            return String(format: "%0i", seconds)
        } else {
            return "0"
        }
    }
}
