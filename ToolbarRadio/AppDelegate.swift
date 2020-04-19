//
//  AppDelegate.swift
//  ToolbarRadio
//
//  Created by Rui Rodrigues on 08/04/2020.
//  Copyright © 2020 brownie. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
  
    var statusBarItem: StatusBarItem!
    var mediator: Mediator!
    var playbackKeysMonitor: PlaybackKeysEventMonitor!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let settings = Settings.shared
        
        statusBarItem = StatusBarItem(settings: .shared)
        statusBarItem.quitMenuItem.target = NSApp
        statusBarItem.quitMenuItem.action = #selector(NSApp.terminate(_:))
        
        let localNotificationCenter = LocalNotificationCenter.shared
        localNotificationCenter.requestPermission()
        
        playbackKeysMonitor = PlaybackKeysEventMonitor(settings: settings)
        playbackKeysMonitor.start()
        
        mediator = Mediator(statusBarItem,
                            Player.shared,
                            NowPlayingFetcher.shared,
                            playbackKeysMonitor,
                            localNotificationCenter,
                            ImagesDownloader.shared,
                            settings)
        mediator.start()

        
//        // Create the SwiftUI view that provides the window contents.
//        let contentView = ContentView()
//
//        // Create the window and set the content view.
//        window = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
//            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//            backing: .buffered, defer: false)
//        window.center()
//        window.setFrameAutosaveName("Main Window")
//        window.contentView = NSHostingView(rootView: contentView)
//        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

