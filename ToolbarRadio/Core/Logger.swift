//
//  Logger.swift
//  ToolbarRadio
//
//  Created by Rui Rodrigues on 24/01/2021.
//  Copyright © 2021 brownie. All rights reserved.
//

import Foundation
import os

extension Logger {
    
    static let `default` = Logger()
    
    static let player = Logger(subsystem: "brown.ie.ToolbarRadio", category: "player")
}
