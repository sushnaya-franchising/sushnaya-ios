//
//  IntroBackgroundVideo.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/18/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation


class IntroVideoPlayer {
    private var player: AVPlayer?
    var layer: AVPlayerLayer?
    
    init(forResource: String, ofType:String) {
        self.player = createLoopingIntroVideoPlayer(forResource: forResource, ofType: ofType)
        self.layer = AVPlayerLayer(player: player)
    }
    
    public func play() {
        player?.isMuted = true
        player?.play()
    }
    
    public func pause() {
        player?.pause()
    }
    
    private func createLoopingIntroVideoPlayer(forResource: String, ofType:String) -> AVPlayer? {
        guard let path = Bundle.main.path(forResource: forResource, ofType: ofType) else {
            debugPrint("intro_video.mp4 not found")
            return nil
        }
        
        let url = URL(fileURLWithPath: path)
        
        if #available(tvOS 10.0, *) {
            return createSeamlessLoopingVideoPlayer(url: url)
            
        } else {
            return createLoopingVideoPlayer(url: url)
        }
    }
    
    private func createSeamlessLoopingVideoPlayer(url: URL) -> AVPlayer {
        let player = AVQueuePlayer()
        looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        
        return player
    }
    
    private func createLoopingVideoPlayer(url: URL) -> AVPlayer {
        let player = AVPlayer(url: url)
        loop(player)
        
        return player
    }
    
    // we have to store reference to loop
    private var looper: NSObject?
    
    private func loop(_ videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            videoPlayer.seek(to: kCMTimeZero)
            videoPlayer.play()
        }
    }
}
