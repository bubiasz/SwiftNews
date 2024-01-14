//
//  NewsModel.swift
//  SwiftNews
//

import Foundation
import SwiftData

@Model
class NewsModel {
    var url: String
    var category: String
    var date: String
    var title: String
    var content: String
    var saved: Bool
    
    init(url: String, category: String, date: String, title: String, content: String, saved: Bool = false) {
        self.url = url
        self.category = category
        self.date = date
        self.title = title
        self.content = content
        self.saved = saved
    }
}
