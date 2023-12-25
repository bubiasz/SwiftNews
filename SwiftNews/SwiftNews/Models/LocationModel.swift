//
//  SwiftNews
//

import SwiftData


@Model
class LocationModel {
    var language: String
    
    @Attribute(.unique)
    var region: String
    var categories: [String]?
    
    init(language: String, region: String, categories: [String]?) {
        self.language = language
        self.region = region
        self.categories = categories
    }
}
