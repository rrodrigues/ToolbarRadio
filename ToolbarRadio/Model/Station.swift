//
//  Station.swift
//  ToolbarRadio
//
//  Created by Rui Rodrigues on 10/04/2020.
//  Copyright © 2020 brownie. All rights reserved.
//

import Foundation

struct Station {
    let id: String
    let name: String
    let streamURL: URL
    var nowPlayingURL: URL? = nil
    var nowPlayingParserType: NowPlayingParserType = .none
}

extension Station : Equatable {
    static func == (lhs: Station, rhs: Station) -> Bool {
        return lhs.id == rhs.id
    }
}

enum NowPlayingParserType {
    case none
    case string
    case xml
}
