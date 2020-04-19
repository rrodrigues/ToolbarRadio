//
//  Mediator.swift
//  ToolbarRadio
//
//  Created by Rui Rodrigues on 10/04/2020.
//  Copyright © 2020 brownie. All rights reserved.
//

import Foundation
import Combine

class Mediator {
    var storage = Set<AnyCancellable>()

    let statusBarItem: StatusBarItem
    let player: Player
    let nowPlayingFetcher: NowPlayingFetcher
    let playbackKeysEventMonitor: PlaybackKeysEventMonitor
    let localNotificationCenter: LocalNotificationCenter
    let imagesDownloader: ImagesDownloader
    let settings: Settings
    
    init(_ statusBarItem: StatusBarItem,
         _ player: Player,
         _ nowPlayingFetcher: NowPlayingFetcher,
         _ playbackKeysEventMonitor: PlaybackKeysEventMonitor,
         _ localNotificationCenter: LocalNotificationCenter,
         _ imagesDownloader: ImagesDownloader,
         _ settings: Settings) {
        
        self.statusBarItem = statusBarItem
        self.player = player
        self.nowPlayingFetcher = nowPlayingFetcher
        self.playbackKeysEventMonitor = playbackKeysEventMonitor
        self.localNotificationCenter = localNotificationCenter
        self.imagesDownloader = imagesDownloader
        self.settings = settings
    }
    
    func start() {
        
        statusBarItem.delegate = self

        let playerStateFork = PassthroughSubject<Player.State, Never>()
        let playerState = player.$state.share().multicast(subject: playerStateFork)
        playerState
            .assign(to: \.state, on: statusBarItem)
            .store(in: &storage)
        
        let currentStationFork = PassthroughSubject<Station?, Never>()
        let currentStation = settings.$currentStation.share().multicast(subject: currentStationFork)
        currentStation
            .compactMap({ $0 })
            .removeDuplicates()
            .filter({ [weak self] _ in
                guard let self = self else { return false }
                return self.player.state == .playing || self.player.state == .loading
            })
            .sink(receiveValue: { [weak self] station in
                guard let self = self else { return }
                self.player.play(url: station.streamURL)
            })
            .store(in: &storage)
        
        
        Publishers.CombineLatest(playerState, currentStation )
            .map({ (state, station) -> (Player.State, Station?) in
                guard state == .playing else { return (state, nil) }
                return (state, station)
            })
            .removeDuplicates(by: {
                return $0.0 == $1.0 && $0.1 == $1.1
            })
            .sink(receiveValue: { [weak self] playerState, currentStation in
                guard let self = self else { return }
                if playerState == .playing, let station = currentStation {
                    self.nowPlayingFetcher.start(station)
                } else {
                    self.nowPlayingFetcher.stop()
                }
            }).store(in: &storage)
        
        playerState
            .connect()
            .store(in: &storage)
        currentStation
            .connect()
            .store(in: &storage)
        
        nowPlayingFetcher.$info
            .removeDuplicates()
            .compactMap({ $0 })
            .flatMap({ [weak self] info -> AnyPublisher<(NowPlaying, URL?), Never> in
                guard let self = self, let cover = info.cover else { return Just((info, nil)).eraseToAnyPublisher() }
                let info = Just(info).eraseToAnyPublisher()
                let image = self.imagesDownloader.download(cover, resize: CGSize(width: 50, height: 50))
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
                return Publishers.Zip(info, image)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                let (info, image) = data
                let playing: String
                if let album = info.album {
                    playing = "\(info.artist) - \(album)"
                } else {
                    playing = info.artist
                }
                print("... \(info.station) -> \(playing)")
                self?.statusBarItem.button.toolTip = "\(info.station) | \(playing)"
                self?.localNotificationCenter.send(info.station, playing, image)
            }).store(in: &storage)
        
        playbackKeysEventMonitor.pressedKey
            .sink(receiveValue: { [weak self] key in
                self?.togglePlayback()
            }).store(in: &storage)
    }
    
}

extension Mediator : StatusBarItemDelegate {
    
    func togglePlayback() {
        guard let url = settings.currentStation?.streamURL else {
            player.stop()
            return
        }
        
        if player.state == .stop || player.state == .error {
            player.play(url: url)
        } else {
            player.stop()
        }
    }
    
    func toggleUsePlaybackKeys() {
        settings.handlePlaybackKeysEvents = !settings.handlePlaybackKeysEvents
    }
}
