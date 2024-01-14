//
//  NewsPostSchema.swift
//  SwiftNews
//

import Foundation

struct NewsPostSchema: Codable{
    let user: String
    let time: Int
    let location: String
    let categories: [String: Int]
}
