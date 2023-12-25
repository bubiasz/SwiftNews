//
//  SwiftNews
//

import SwiftData
import SwiftUI


@main
struct SwiftNewsApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(for: [UserModel.self, LocationModel.self, NewsModel.self])
    }
}
