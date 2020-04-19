//
//  Settings.swift
//  ToolbarRadio
//
//  Created by Rui Rodrigues on 10/04/2020.
//  Copyright © 2020 brownie. All rights reserved.
//

import Foundation
import Combine

class Settings {
    struct Keys {
        static let selectedStation: String = "selected_station"
        static let stationsList: String = "stations_list"
        static let handlePlaybackKeysEvents: String = "handle_playback_keys_wvents"
    }
    
    static let shared = Settings()
    
    var storage = Set<AnyCancellable>()
    
    private let userDefaults = UserDefaults.standard
    
    let stationsList = [
        Station(id: "radarfm",
                name: "Radar 97.8fm",
                streamURL: URL(string: "https://scast1.evspt.com/radar_aac")!,
                nowPlayingURL: URL(string: "https://www.radarlisboa.fm/avaplayer/onair.txt")!,
                nowPlayingParserType: .string
        ),
        Station(id: "comercial",
                name: "Comercial",
                streamURL: URL(string: "https://mcrscast1.mcr.iol.pt/comercial.mp3")!,
                nowPlayingURL: URL(string: "https://radiocomercial.iol.pt/nowplaying.xml")!,
                nowPlayingParserType: .xml
        ),
    ]
    
    var handlePlaybackKeysEvents: Bool {
        get { userDefaults.bool(forKey: Keys.handlePlaybackKeysEvents) }
        set { userDefaults.set(newValue, forKey: Keys.handlePlaybackKeysEvents) }
    }
    
    init() {
        let selected = "radarfm"
        userDefaults.register(defaults: [
            Keys.selectedStation : selected,
            Keys.handlePlaybackKeysEvents : true
        ])
        
        let id = userDefaults.string(forKey: Keys.selectedStation) ?? selected
        currentStation = stationsList.first(where: { $0.id == id })
        
        $currentStation
            .compactMap({ $0 })
            .removeDuplicates()
            .map({ ( Keys.selectedStation, $0.id) })
            .sink(receiveValue: { [weak self] in self?.userDefaults.set($0.1, forKey: $0.0) })
            .store(in: &storage)
    }
    
    @Published
    var currentStation: Station?
    
//    var currentStation: URL = URL(string: "https://scast1.evspt.com/radar_aac")!
//    var currentStation: URL = URL(string: "https://mcrscast1.mcr.iol.pt/comercial.mp3")!
//    var currentStation: URL = URL(string: "https://mcrwowza6.mcr.iol.pt/comercial/smil:comercial.smil/playlist.m3u8")!

}
