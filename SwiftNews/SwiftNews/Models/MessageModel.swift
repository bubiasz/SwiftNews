//
//  MessageModel.swift
//  SwiftNews
//

import Foundation
import SwiftData

@Model
class MessageModel {
    @Attribute(.unique)
    var id: Int
    var message: String
    
    init(id: Int, message: String) {
        self.id = id
        self.message = message
    }
}
