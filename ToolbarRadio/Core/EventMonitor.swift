//
//  EventMonitor.swift
//  ToolbarRadio
//
//  Created by Rui Rodrigues on 08/04/2020.
//  Copyright © 2020 brownie. All rights reserved.
//

import Foundation
import AppKit
import Combine

class EventMonitor {

    var monitor: Any?
    
    deinit {
        stop()
    }
    
    func start() {}
    
    func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}

class GlobalEventMonitor : EventMonitor {
    
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    override func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }
}


class PlaybackKeysEventMonitor : EventMonitor {
    
    enum Key {
        case previous
        case playPause
        case next
    }

    let pressedKey = PassthroughSubject<Key, Never>()
    
    private let settings: Settings
    private let playbackKeysCodes: [Int: Key] = [
//        Int(NX_KEYTYPE_PREVIOUS) : .previous,
        Int(NX_KEYTYPE_PLAY) : .playPause,
//        Int(NX_KEYTYPE_NEXT) : .next,
    ]
    
    init(settings: Settings) {
        self.settings = settings
    }
    
    override func start() {
        self.monitor = NSEvent.addLocalMonitorForEvents(matching: .systemDefined, handler: { [weak self] event in
            guard let self = self else { return event }
            guard self.settings.handlePlaybackKeysEvents else { return event }
            
            let keyFlags = (event.data1 & 0x0000FFFF)
            // Get the key state. 0xA is KeyDown, OxB is KeyUp
            let keyDown = (((keyFlags & 0xFF00) >> 8)) == 0xB
            guard event.subtype == .screenChanged, keyDown else { return event }

            let keyCode = ((event.data1 & 0xFFFF0000) >> 16)
            guard let key = self.playbackKeysCodes[keyCode] else { return event }
            
            self.pressedKey.send(key)
            
            return nil
        })
    }
}
