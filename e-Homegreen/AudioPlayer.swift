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
    
    private var player: AVQueuePlayer!
    private var url: URL?
    
    func playAudioFrom(url: URL) {
        if url != self.url {
            let item = AVPlayerItem(url: url)
            player = AVQueuePlayer(playerItem: item)
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
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
