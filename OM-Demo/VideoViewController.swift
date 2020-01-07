//
//  VideoViewController.swift
//  OM-Demo
//
//  Created by Justin Hines on 11/6/17.
//

import UIKit
import AVKit
import OMSDK_Demoapp

enum Quartile {
    case Init
    case start
    case firstQuartile
    case midpoint
    case thirdQuartile
    case complete
}

class VideoViewController: BaseAdUnitViewController {
    
    @IBOutlet var videoView: UIView?
    @IBOutlet var playButton: UIButton!
    @IBOutlet var controls: UIView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!

    var omidMediaEvents: OMIDDemoappMediaEvents?
    var currentQuartile: Quartile = .Init

    override var creativeURL: URL {
        //URL to a video asset. In a real world scenario, this would come from a VAST document or a similar format.
        return URL(string: Constants.videoAdURL)!
    }

    var localAssetURL: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("asset.mp4")
    }

    override func didFinishFetchingCreative(_ fileURL: URL) {
        try? FileManager.default.moveItem(at: fileURL, to: localAssetURL)
        NSLog("Did finish fetching creative.")
        createMediaPlayer(withAssetURL: localAssetURL)
        resetTimeLabels()
        addQuartileTrackingToVideoPlayer()
        attachPauseButtonImage()

        presentAd()
    }

    override func willPresentAd() {
        super.willPresentAd()

        //Start playback
        play()
    }

    override func destroyAd() {
        hidePlayerControls()

        guard let videoPlayerLayer = playerLayer else { return }
        videoPlayerLayer.player = nil
        videoPlayerLayer.removeFromSuperlayer()
        try? FileManager.default.removeItem(at: localAssetURL)
    }

    override func presentAd() {
        super.presentAd()
        showPlayerControls()
    }

    override func createAdSessionContext(withPartner partner: OMIDDemoappPartner) -> OMIDDemoappAdSessionContext {
        //Ad Verification
        //These values should be parsed from the VAST document

        //In this example we don't parse VAST, but if we did, the <AdVerifications> node would look like this:
        //<AdVerifications>
        //  <Verification vendor="iabtechlab.com-omid">
        //      <JavaScriptResource apiFramework="omid" browserOptional=”true”>
        //          <![CDATA[https://server.com/omid-validation-verification-script-v1.js]]>
        //      </JavaScriptResource>
        //      <VerificationParameters>
        //          <![CDATA[parameterstring]]>
        //      </VerificationParameters>
        //  </Verification>
        //</AdVerifications>

        //Usign validation verification script as an example
        let urlToMeasurementScript = Constants.verificationScriptURL
        //Vendor key
        let vendorKey = Constants.vendorKey
        //Verification Parameters. This is just an arbitary string, however with validation verification script, the value that is passed here will be used as a remote URL for tracking events
        let parameters = Constants.verificationParameters

        //Create verification resource for <AdVerification> from above
        guard let verificationResource = createVerificationScriptResource(vendorKey: vendorKey,
                                                                          verificationScriptURL: urlToMeasurementScript,
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
            return try
                OMIDDemoappAdSessionConfiguration(creativeType: .video,
                                           impressionType: .beginToRender,
                                           impressionOwner: .nativeOwner,
                                           mediaEventsOwner: .nativeOwner,
                                           isolateVerificationScripts: false)
        } catch {
            fatalError("Unable to create ad session configuration: \(error)")
        }
    }

    override func setupAdditionalAdEvents(adSession: OMIDDemoappAdSession) {
        do {
            omidMediaEvents = try OMIDDemoappMediaEvents(adSession: adSession)
        } catch {
            fatalError("Unable to instantiate video ad events")
        }
    }
    
    override func adLoaded() {
        //Report VAST properties to OMID
        //The values should be parsed from the VAST document
        let VASTProperties = OMIDDemoappVASTProperties(autoPlay: true, position: .standalone)
        
        do {
            try adEvents?.loaded(with: VASTProperties)
        } catch {
            fatalError("Unable to trigger loaded event: \(error)")
        }
    }
    
    // MARK: - Player Controls
    
    var player: AVPlayer? {
        return playerLayer?.player
    }
    
    var playerLayer: AVPlayerLayer? {
        guard let videoView = videoView, let videoPlayerLayer = videoView.layer.sublayers?.first as? AVPlayerLayer else {
            return nil
        }
        return videoPlayerLayer
    }
    
    func createMediaPlayer(withAssetURL assetURL: URL) {
        let asset = AVURLAsset(url: assetURL)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
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

extension VideoViewController {
    @IBAction func tappedPlayingControl() {
        if player?.currentItem?.currentTime() == player?.currentItem?.duration {
            return
        }
        changePlayingControls()
    }
    
    func changePlayingControls() {
        if let player = player, player.rate == 0 {
            play()
            attachPauseButtonImage()
            omidMediaEvents?.resume()
        } else {
            pause()
            attachPlayButtonImage()
            omidMediaEvents?.pause()
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
    
    func hidePlayerControls() {
        UIView.animate(withDuration: 0.5) {
            self.controls.alpha = 0
            self.startTimeLabel.alpha = 0
            self.endTimeLabel.alpha = 0
        }
    }
    
    func showPlayerControls() {
        UIView.animate(withDuration: 0.5) {
            self.controls.alpha = 1.0
            self.startTimeLabel.alpha = 1.0
            self.endTimeLabel.alpha = 1.0
        }
    }

    @IBAction func toggleMute() {
        guard let player = player else {
            return
        }

        player.isMuted = !player.isMuted
        muteButton.isSelected = player.isMuted
        omidMediaEvents?.volumeChange(to: playerVolume())
    }

    @IBAction func handleClick() {
        omidMediaEvents?.adUserInteraction(withType: .click)
        let clickThroughURL = URL(string: "https://www.pandora.com/artist/fall-out-boy/mania/ALJxxPp4qfg6wvg")!
        UIApplication.shared.openURL(clickThroughURL)
    }

    func playerVolume() -> CGFloat {
        guard let player = player else {
            return 0.0
        }

        if player.isMuted {
            return 0.0
        }

        return CGFloat(player.volume)
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
                omidMediaEvents?.start(withDuration: CGFloat(duration), mediaPlayerVolume: playerVolume())
                currentQuartile = .start
            }
        case .start:
            if (progressPercent > Double(1)/Double(4)) {
                omidMediaEvents?.firstQuartile()
                currentQuartile = .firstQuartile
            }
        case .firstQuartile:
            if (progressPercent > Double(1)/Double(2)) {
                omidMediaEvents?.midpoint()
                currentQuartile = .midpoint
            }
        case .midpoint:
            if (progressPercent > Double(3)/Double(4)) {
                omidMediaEvents?.thirdQuartile()
                currentQuartile = .thirdQuartile
            }
        case .thirdQuartile:
            if (progressPercent >= 1.0) {
                omidMediaEvents?.complete()
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
