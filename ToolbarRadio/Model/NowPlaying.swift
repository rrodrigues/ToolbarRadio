//
//  NowPlaying.swift
//  ToolbarRadio
//
//  Created by Rui Rodrigues on 11/04/2020.
//  Copyright © 2020 brownie. All rights reserved.
//

import Foundation
import AppKit

struct NowPlaying {
    let station: String
    let artist: String
    let music: String
    var album: String?
    var cover: URL? = nil
}

extension NowPlaying : Equatable {
    
}
