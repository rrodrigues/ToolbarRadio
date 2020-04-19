//
//  StatusBarItem.swift
//  ToolbarRadio
//
//  Created by Rui Rodrigues on 09/04/2020.
//  Copyright © 2020 brownie. All rights reserved.
//

import Foundation
import AppKit

protocol StatusBarItemDelegate : class {
    func togglePlayback()
    func toggleUsePlaybackKeys()
}

class StatusBarItem {
    
    var state: Player.State = .stop {
        didSet {
            button.title = titleForState(state)
            button.image = iconForState(state)
        }
    }
    
    let settings: Settings
    let item: NSStatusItem
    let button: NSStatusBarButton
    let menu: NSMenu
    let stationsMenu: NSMenu
    
    let playbackKeysMenuItem: NSMenuItem
    let quitMenuItem: NSMenuItem
    
    weak var delegate: StatusBarItemDelegate?

    init(settings: Settings) {
        self.settings = settings
        
        let statusBar = NSStatusBar.system
        item = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        button = item.button!
        menu = NSMenu(title: "Menu")
        stationsMenu = NSMenu(title: "Stations")
        playbackKeysMenuItem = NSMenuItem(title: "Use playback keys", action: nil, keyEquivalent: "")
        quitMenuItem = NSMenuItem(title: "Quit", action: nil, keyEquivalent: "")
        
        item.isVisible = true
        item.behavior = .terminationOnRemoval

        button.title = titleForState(state)
        button.image = iconForState(state)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        button.action = #selector(itemClicked(_:))
        button.target = self
        
        playbackKeysMenuItem.action = #selector(toggleUsePlaybackKeys)
        playbackKeysMenuItem.target = self
        playbackKeysMenuItem.state = settings.handlePlaybackKeysEvents ? .on : .off
        
        let stationsMenuItem = menu.addItem(withTitle: stationsMenu.title, action: nil, keyEquivalent: "")
        stationsMenuItem.submenu = stationsMenu
        for station in settings.stationsList {
            let m = stationsMenu.addItem(withTitle: station.name, action: #selector(stationSelected(_:)), keyEquivalent: "")
            m.target = self
            m.representedObject = station
        }
        updateSelectedStation(settings.currentStation)
        menu.addItem(playbackKeysMenuItem)
        menu.addItem(quitMenuItem)
    }
    
    private func titleForState(_ state: Player.State) -> String {
        switch state {
        case .stop: return "▶"
        case .loading: return "L"
        case .playing: return ""
        case .error: return "E"
        }
    }
    
    private func iconForState(_ state: Player.State) -> NSImage? {
        switch state {
        case .stop: return nil
        case .loading: return nil
        case .playing: return NSImage(named: "playing")
        case .error: return nil
        }
    }
    
    private func updateSelectedStation(_ station: Station?) {
        let id = settings.currentStation?.id ?? ""
        for m in stationsMenu.items {
            guard let station = m.representedObject as? Station else { continue }
            m.state = station.id == id ? .on : .off
        }
    }
    
    @objc func itemClicked(_ sender: Any?) {
        guard let event = NSApplication.shared.currentEvent else { return }
        
        if event.type == .rightMouseUp || event.modifierFlags.contains(.control) || event.modifierFlags.contains(.option) {
            // show menu
            showMenu()
        } else {
            delegate?.togglePlayback()
        }
    }
    
    @objc func toggleUsePlaybackKeys(_ sender: Any?) {
        guard let item = sender as? NSMenuItem else { return }
        delegate?.toggleUsePlaybackKeys()
        item.state = settings.handlePlaybackKeysEvents ? .on : .off
    }
    
    @objc func stationSelected(_ sender: Any?) {
        guard let item = sender as? NSMenuItem else { return }
        guard let station = item.representedObject as? Station else { return }
        settings.currentStation = station
        updateSelectedStation(station)
    }

    func showMenu() {
        guard let button = item.button else { return }
        let point = CGPoint(x: button.bounds.minX, y: button.bounds.maxY + 6)
        menu.popUp(positioning: nil, at: point, in: button)
    }
}
