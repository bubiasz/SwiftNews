//
//  CodeSchema.swift
//  SwiftNews
//

import Foundation

struct CodeSchema: Codable {
    let user: String
    let time: Int
    let location: String
    let categories: [String: Int]
}
