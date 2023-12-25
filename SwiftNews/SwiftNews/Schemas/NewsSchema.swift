//
//  SwiftNews
//

import Foundation


struct NewsSchema: Codable {
    let category: String
    let url: String
    let date: String
    let title: String
    let content: String
}
