//
//  SwiftNews
//

import SwiftData


@Model
class CategoryModel {
    @Attribute(.unique)
    var name: String
    var value: Int
    
    init(name: String, value: Int) {
        self.name = name
        self.value = value
    }
}
