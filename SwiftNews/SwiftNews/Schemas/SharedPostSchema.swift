//
//  SharedSchema.swift
//  SwiftNews
//

import Foundation

struct SharedPostSchema: Codable {
    let user: String
    let url: String
    let date: String
    let title: String
    let content: String
    let category: String
}
