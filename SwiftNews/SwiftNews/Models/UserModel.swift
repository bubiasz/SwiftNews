//
//  SwiftNews
//

import SwiftData


@Model
class UserModel {
    var id: String
    var time: Int
    var location: String
    var categories: [String: Int]?
    
    init(id: String, time: Int = 10, location: String = "US", categories: [String: Int]? = nil) {
        self.id = id
        self.time = time
        self.location = location
        self.categories = categories
    }
}
