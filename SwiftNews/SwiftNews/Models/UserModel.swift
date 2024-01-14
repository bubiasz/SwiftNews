//
//  UserModel.swift
//  SwiftNews
//

import Foundation
import SwiftData

@Model
class UserModel {
    var id: String
    var time: Int
    var location: String
    var categories: [String: Int]
    
    init(id: String, time: Int, location: String, categories: [String: Int]) {
        self.id = id
        self.time = time
        self.location = location
        self.categories = categories
    }
}
