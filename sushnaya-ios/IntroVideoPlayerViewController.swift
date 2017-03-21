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


class IntroVideoPlayerViewController: AVPlayerViewController {
    
    // todo: handle case when someone calls
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoGravity = AVLayerVideoGravityResizeAspectFill
        showsPlaybackControls = false
        
        player = createLoopingVideoPlayer(forResource: "intro_video", ofType: "mp4")
        player?.isMuted = true
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(IntroVideoPlayerViewController.applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IntroVideoPlayerViewController.applicationDidBecomeActive(notification:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationWillResignActive(notification: NSNotification) {
        player?.pause()
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        player?.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player?.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player?.pause()
    }
    
    private func createLoopingVideoPlayer(forResource: String, ofType:String) -> AVPlayer? {
        guard let path = Bundle.main.path(forResource: forResource, ofType: ofType) else {
            debugPrint("\(forResource)\(ofType) not found")
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
        let player = AVQueuePlayer(items: [AVPlayerItem(url: url)])
        looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        
        return player
    }
    
    private func createLoopingVideoPlayer(url: URL) -> AVPlayer {
        let player = AVPlayer(url: url)
        loop(player)
        
        return player
    }
    
    // we have to store looper reference for looping
    private var looper: NSObject?
    
    private func loop(_ videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            videoPlayer.seek(to: kCMTimeZero)
            videoPlayer.play()
        }
    }
}
