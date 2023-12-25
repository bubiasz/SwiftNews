//
//  SwiftNews
//

import Foundation


struct ConfigSchema: Codable {
    let language: String
    let region: String
    let categories: [String]?
}
