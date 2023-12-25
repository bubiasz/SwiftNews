//
//  SwiftNews
//

import Foundation


struct CodeSchema: Codable {
    let user: String
    let time: Int
    let region: String
    let language: String
    let categories: [String: Int]
}
