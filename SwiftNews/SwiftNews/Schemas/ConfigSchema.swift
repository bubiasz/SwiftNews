//
//  SwiftNews
//

import Foundation


struct ConfigItem: Codable {
    let language: String
    let region: String
    let categories: [String]
}

struct ConfigSchema: Codable {
    let times: [Int]
    let locations: [ConfigItem]
}
