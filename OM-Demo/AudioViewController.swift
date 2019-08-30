//
//  AudioViewController.swift
//  OM-Demo
//
//  Created by Justin Hines on 8/20/19.
//  Copyright © 2019 Open Measurement Working Group. All rights reserved.
//

import UIKit
import AVFoundation

class AudioViewController: VideoViewController {
    var audioPlayer: AVPlayer?
    
    override var player: AVPlayer? {
        return audioPlayer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adUnit = .nativeAudio
    }
    
    override var localAssetURL: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("asset.mp3")
    }
    
    override var creativeURL: URL {
        //URL to a video asset. In a real world scenario, this would come from a VAST document or a similar format.
        return URL(string: Constants.audioAdURL.absoluteString)!
    }
    
    override func createMediaPlayer(withAssetURL assetURL: URL) {
        let asset = AVURLAsset(url: assetURL)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        player.volume = 1.0
        
        self.audioPlayer = player
    }
    
    override func createAdSessionConfiguration() -> OMIDAdSessionConfiguration {
        //Create ad session configuration
        do {
            return try
                OMIDAdSessionConfiguration(creativeType: .audio, impressionType: .audible, impressionOwner: .nativeOwner, mediaEventsOwner: .nativeOwner, isolateVerificationScripts: false)
        } catch {
            fatalError("Unable to create ad session configuration: \(error)")
        }
    }

}
