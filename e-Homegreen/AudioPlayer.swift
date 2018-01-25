//
//  AudioPlayer.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 1/25/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer {
    
    static let sharedInstance = AudioPlayer()
    
    private var player: AVPlayer!
    private var url: URL?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(stopAudio), name: .appIsExiting, object: nil)
        // TODO: notification for exiting app
    }
    
    func playAudioFrom(url: URL) {
        if url != self.url {
            player = AVPlayer(url: url)
            player.volume = 1.0
            player.play()
            
            self.url = url
        } else {
            guard player != nil else { return }
            player.play()
        }
        
    }
    
    func pauseAudio() {
        guard player != nil else { return }
        player.pause()
    }
    
    @objc func stopAudio() {
        guard player != nil else { return }
        player.pause()
        player = nil
        url = nil
    }
    
    
    
}

extension Notification.Name {
    static let appIsExiting = Notification.Name("appIsExiting")
}
