//
//  ConfigModel.swift
//  SwiftNews
//

import Foundation
import SwiftData

@Model
class ConfigModel {
    var times: [Int]
    var locations: [String: [String]]
    
    init(times: [Int], locations: [String: [String]]) {
        self.times = times
        self.locations = locations
    }
}
