//
//  NewsSchema.swift
//  SwiftNews
//

import Foundation

struct NewsSchema: Codable {
    let url: String
    let date: String
    let title: String
    let content: String
    let category: String
}
