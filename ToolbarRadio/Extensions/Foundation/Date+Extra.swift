//
//  Date+Extra.swift
//  ToolbarRadio
//
//  Created by Rui Rodrigues on 11/04/2020.
//  Copyright © 2020 brownie. All rights reserved.
//

import Foundation
import SwifterSwift


extension Date {
    
    static var d: String {
        return Date().string(withFormat: "[yyyy-MM-dd HH:mm:ss.SSS]")
    }
    
}
