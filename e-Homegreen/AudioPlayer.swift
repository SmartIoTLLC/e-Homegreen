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

class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    private struct SmartIoTPlayerItem {
        let url: URL!
        let title: String!
        let artist: String!
        let genre: String!
    }
    
    static let sharedInstance = AudioPlayer()
    
    private var nowPlayingIndex: Int = 0
    
    private var playlist: [SmartIoTPlayerItem] = []
    
    private var player: AVQueuePlayer!
    private var url: URL?
    private let audioInfo = MPNowPlayingInfoCenter.default()
    private let audioRemoteCenter = MPRemoteCommandCenter.shared()
    
    var isActive: Bool = false
    
    @objc func autoplay() {
        if isActive {
            playNext()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            if isActive {
                playNext()
            }
        }
    }
    
    func play() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let playlistItem = playlist[nowPlayingIndex]
        
        if playlistItem.url != self.url {
            let item = AVPlayerItem(url: playlistItem.url)
            audioInfo.nowPlayingInfo = [
                MPMediaItemPropertyArtist: playlistItem.artist,
                MPMediaItemPropertyTitle: playlistItem.title,
                MPMediaItemPropertyGenre: playlistItem.genre
            ]
            NotificationCenter.default.post(name: .nowPlayingItemChanged, object: playlistItem.title)
            NotificationCenter.default.addObserver(self, selector: #selector(autoplay), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            player = AVQueuePlayer(playerItem: item)
            
            try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP, .allowAirPlay, .mixWithOthers])            
            
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
        if nowPlayingIndex + 1 == playlist.count { nowPlayingIndex = 0 } else { nowPlayingIndex += 1 }
        play()
    }
    func playPrevious() {
        if nowPlayingIndex - 1 < 0 { nowPlayingIndex = playlist.count - 1 } else { nowPlayingIndex -= 1 }
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
        NotificationCenter.default.removeObserver(self)
    }
    
    private func getFormattedSuraID(id: NSNumber) -> String {
        if String(describing: id).count == 1 { return "00" + String(describing: id) }
        if String(describing: id).count == 2 { return "0" + String(describing: id) }
        return String(describing: id)
    }
    
}

extension Notification.Name {
    static let nowPlayingItemChanged = Notification.Name("nowPlayingItemChanged")
}
