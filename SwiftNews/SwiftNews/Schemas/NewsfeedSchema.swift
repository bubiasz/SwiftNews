//
//  SwiftNews
//

import Foundation


struct NewsfeedSchema: Codable{
    let user: String
    let time: Int
    let location: String
    let categories: [String: Int]
}
