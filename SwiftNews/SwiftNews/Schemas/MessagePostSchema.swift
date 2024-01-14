//
//  MessageSchema.swift
//  SwiftNews
//

import Foundation

struct MessagePostSchema: Codable {
    let user: String
    let title: String
    let message: String
}
