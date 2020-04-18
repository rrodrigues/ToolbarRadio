//
//  Player.swift
//  ToolbarRadio
//
//  Created by Rui Rodrigues on 10/04/2020.
//  Copyright © 2020 brownie. All rights reserved.
//

import Foundation
import Combine
import AVFoundation

class Player : NSObject {
    
    static let shared = Player()
    
    enum State {
        case stop
        case loading
        case playing
        case error
    }
    
    var storage = Set<AnyCancellable>()
    
    private let player = AVPlayer()
    private let metadataCollector = AVPlayerItemMetadataCollector()
    
    private let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]

    @Published
    var state: State = .stop
    
    override init() {
        super.init()
        
        metadataCollector.setDelegate(self, queue: .main)
    }
    
    func play(url: URL) {
        state = .loading
        
        player.pause()
        removeCurrentItem()
        
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: requiredAssetKeys)
        item.add(metadataCollector)
        item.publisher(for: \.status, options: [.initial, .new])
            .compactMap({ status -> State? in
                switch status {
                case .failed: return .error
                case .readyToPlay: return .playing
                default: return nil
                }
            })
            .sink(receiveValue: { [weak self] in self?.state = $0 })
            .store(in: &storage)
        
        player.replaceCurrentItem(with: item)
        player.play()
    }
    
    func stop() {
        player.pause()
        removeCurrentItem()
        state = .stop
    }
    
    private func removeCurrentItem() {
        if let item = player.currentItem, item.mediaDataCollectors.contains(metadataCollector) {
            item.remove(metadataCollector)
        }
        player.replaceCurrentItem(with: nil)
    }
}

extension Player : AVPlayerItemMetadataCollectorPushDelegate {
    
    func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector, didCollect metadataGroups: [AVDateRangeMetadataGroup], indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
        
        print("metadata....")
        metadataGroups.forEach({ print($0.attributeKeys) })
        
    }
    
}
