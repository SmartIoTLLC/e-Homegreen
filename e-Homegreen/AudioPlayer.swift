//
//  AudioPlayer.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 1/25/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import UIKit

class AudioPlayer {
    
    struct SmartIoTPlayerItem {
        let url: URL!
        let title: String!
        let artist: String!
        let genre: String!
    }
    
    static let sharedInstance = AudioPlayer()

    private var nowPlayingIndex: Int = 0
    var nowPlayingItem: SmartIoTPlayerItem! {
        didSet {
            NotificationCenter.default.post(name: .nowPlayingItemChanged, object: nowPlayingItem.title)
        }
    }
    private var playlist: [SmartIoTPlayerItem] = []
    
    private var player: AVQueuePlayer!
    private var url: URL?
    private let audioInfo = MPNowPlayingInfoCenter.default()
    private let audioRemoteCenter = MPRemoteCommandCenter.shared()
    
    var isActive: Bool = false
    
    func handleRemoteControlEvent(_ event: UIEvent?, label: inout UILabel!) {
        if isActive {
            if let event = event {
                switch event.subtype {
                    case .remoteControlPlay          : play()
                    case .remoteControlPause         : pauseAudio()
                    case .remoteControlStop          : stopAudio()
                    case .remoteControlNextTrack     : playNext()
                    case .remoteControlPreviousTrack : playPrevious()
                    default: break
                }
            }
        }
    }
    
    func play() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let playlistItem = playlist[nowPlayingIndex]
        nowPlayingItem = playlistItem
        
        if playlistItem.url != self.url {
            let item = AVPlayerItem(url: playlistItem.url)
            audioInfo.nowPlayingInfo = [
                MPMediaItemPropertyArtist: playlistItem.artist,
                MPMediaItemPropertyTitle: playlistItem.title,
                MPMediaItemPropertyGenre: playlistItem.genre
            ]
            player = AVQueuePlayer(playerItem: item)
            
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            
            player.play()
            
            self.url = playlistItem.url
            isActive = true
        } else {
            guard player != nil else { return }
            player.play()
        }
    }
    
    func loadPlaylist(stations: [Radio]? = nil, suras: [Sura]? = nil, currentIndex: Int) {
        playlist = []
        if let stations = stations {
            stations.forEach({ (station) in
                if let url = URL(string: station.url!) {
                    playlist.append(
                        SmartIoTPlayerItem(
                            url: url,
                            title: station.stationName!,
                            artist: station.city!,
                            genre: station.genre!)
                    )
                }
            })
            nowPlayingIndex = currentIndex
            
            play()
        }
        if let suras = suras {
            suras.forEach({ (sura) in
                if let server = sura.reciter?.server {
                    if let id = sura.id {
                        let urlString = server + "/" + getFormattedSuraID(id: id) + ".mp3"
                        if let url = URL(string: urlString) {
                            playlist.append(
                                SmartIoTPlayerItem(
                                    url: url,
                                    title: sura.name!,
                                    artist: sura.reciter?.name!,
                                    genre: "Quran"
                                )
                            )
                        }
                    }
                }
            })
            nowPlayingIndex = currentIndex
            
            play()
        }

    }
    
    func playNext() {
        if nowPlayingIndex + 1 == playlist.count {
            nowPlayingIndex = 0
        } else {
            nowPlayingIndex += 1
        }
        play()
    }
    func playPrevious() {
        if nowPlayingIndex - 1 < 0 {
            nowPlayingIndex = playlist.count - 1
        } else {
            nowPlayingIndex -= 1
        }
        play()
    }
    
    @objc func pauseAudio() {
        guard player != nil else { return }
        player.pause()
    }
    
    @objc func stopAudio() {
        guard player != nil else { return }
        audioInfo.nowPlayingInfo = [:]
        player.pause()
        player = nil
        url = nil
        UIApplication.shared.endReceivingRemoteControlEvents()
        isActive = false
    }
    
    func getFormattedSuraID(id: NSNumber) -> String {
        if String(describing: id).count == 1 { return "00" + String(describing: id) }
        if String(describing: id).count == 2 { return "0" + String(describing: id) }
        return String(describing: id)
    }
    
}

extension Notification.Name {
    static let nowPlayingItemChanged = Notification.Name("nowPlayingItemChanged")
}
