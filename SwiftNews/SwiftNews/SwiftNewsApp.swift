//
//  SwiftNewsApp.swift
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
        .modelContainer(for: [ConfigModel.self, UserModel.self, NewsModel.self, MessageModel.self])
    }
}
