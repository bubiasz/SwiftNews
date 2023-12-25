//
//  SwiftNews
//

import Foundation


struct NewsfeedSchema: Codable{
    let user: String
    let time: Int
    let region: String
    let language: String
    let categories: [String: Int]
}
