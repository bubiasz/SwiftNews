//
//  ConfigSchema.swift
//  SwiftNews
//

import Foundation

struct Location: Codable {
    let region: String
    let language: String
    let categories: [String]
}

struct ConfigSchema: Codable {
    let times: [Int]
    let locations: [Location]
}
