//
//  NowPlayingFetcher.swift
//  ToolbarRadio
//
//  Created by Rui Rodrigues on 11/04/2020.
//  Copyright © 2020 brownie. All rights reserved.
//

import Foundation
import Combine

class NowPlayingFetcher {
    
    static let shared = NowPlayingFetcher()
    
    private let period: TimeInterval = 10
    private let session: URLSession = .shared
    private let queue = DispatchQueue(label: "queue.now_playing_fetcher")
    private var station: Station?
    
//    private var requestCancellable: AnyCancellable?
    var storage = Set<AnyCancellable>()
    
    @Published
    private(set) var info: NowPlaying?
    
    func start(_ station: Station?) {
        stop()
        self.station = station
        fetch()
    }
    
    func stop() {
        storage.removeAll()
        info = nil
    }
    
    private func fetch(delay: TimeInterval = 0) {
        guard let station = station else { return }
        guard let url = station.nowPlayingURL else { return }
        let dataParser = parser(for: station)
        
        let request = self.session.dataTaskPublisher(for: url)
            .compactMap({ $0.data })
            .replaceError(with: Data())
            .compactMap({ dataParser?($0) })
        
        Just(())
            .delay(for: .seconds(delay), scheduler: queue)
            .flatMap({ request })
            .removeDuplicates()
            .sink(receiveValue: { [weak self] info in
                guard let self = self else { return }
                self.info = info
                self.fetch(delay: self.period)
            })
            .store(in: &storage)
    }
    
    private func parser(for station: Station) -> NowPlayingParser? {
        switch station.nowPlayingParserType {
        case .string:
            return StringParser(station: station.name)
        case .xml:
            return XmlParser()
        default:
            return nil
        }
    }
}

protocol NowPlayingParser {
    func callAsFunction(_ data: Data) -> NowPlaying?
}

extension NowPlayingFetcher {
        
    struct StringParser : NowPlayingParser {
        let station: String
        func callAsFunction(_ data: Data) -> NowPlaying? {
            guard let text = String(data: data, encoding: .utf8) else { return nil }
            return NowPlaying(station: station, artist: text, music: "")
        }
    }
    
    
    class XmlParser : NSObject, NowPlayingParser, XMLParserDelegate {
        func callAsFunction(_ data: Data) -> NowPlaying? {
            guard !data.isEmpty else { return nil }
            let parser = XMLParser(data: data)
            parser.delegate = self
            guard parser.parse() else { return nil }
            
            guard let album = elements["DB_ALBUM_NAME"] else { return nil }
            guard let artist = elements["DB_DALET_ARTIST_NAME"] else { return nil }
            guard let song = elements["DB_SONG_NAME"] else { return nil }
            guard let radio = elements["DB_RADIO_NAME"] else { return nil }
            let cover = elements["DB_ALBUM_IMAGE"]
            let url = cover != nil ? URL(string: "https://radiocomercial.iol.pt/upload/album/\(cover!)") : nil
            
            return NowPlaying(station: radio,
                              artist: artist,
                              music: song,
                              album: album,
                              cover: url)
        }
        
        let elementsToSave = [
            "DB_ALBUM_NAME",
            "DB_ALBUM_IMAGE",
            "DB_DALET_ARTIST_NAME",
            "DB_SONG_NAME",
            "DB_RADIO_NAME"
        ]
        var elementKey: String?
        var elements: [String: String] = [:]
        
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            elementKey = elementsToSave.contains(elementName) ? elementName : nil
        }
        
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            elementKey = nil
        }
        
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            guard let key = elementKey else { return }
            let text = elements[key] ?? ""
            elements[key] = text + string
        }
        
    }
    
    
    
}
