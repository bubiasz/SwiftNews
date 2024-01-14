//
//  SplashView.swift
//  SwiftNews
//

import Foundation
import SwiftData
import SwiftUI

struct SplashView: View {
    // Database connection
    @Environment(\.modelContext) private var modelContext
    @Query private var userQuery: [UserModel]
    @Query(filter: #Predicate<NewsModel> { $0.saved == false }) private var newsQuery: [NewsModel]
    
    // onAppear variables
    @State private var user: UserModel?
    @State private var config: ConfigModel?
    
    // animation variables
    @State private var finished: Bool = false
    @State private var state: RotationState = .min
    
    // alert variables
    @State private var alert: Bool = false
    
    // shared news variables
    @State private var isSheetVisible: Bool = false
    @State private var sharedNews: NewsModel? = nil
    
    private enum RotationState: Int {
        case max
        case min
    }
    
    // View implementation
    var body: some View {
        ZStack {
            if !self.finished {
                VStack {
                    Image(uiImage: UIImage(named: "AppIcon")!)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10.0)
                        .frame(width: 150, height: 150)
                        .overlay(RoundedRectangle(cornerRadius: 10.0)
                            .stroke(Color("foreground"), lineWidth: 2))
                        .rotationEffect(state == .max ? .degrees(-45) : .degrees(45) , anchor: .center)
                        .padding(.bottom, 75)
                        .onAppear {
                            let repeated = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
                            withAnimation(repeated) {
                                switch state {
                                    case .max:
                                        state = .min
                                    case .min:
                                        state = .max
                                }
                            }
                        }
                    
                    Text("SwiftNews")
                        .font(.title)
                        .bold()
                    
                    Text("Your daily informant")
                }
                .padding()
            }
            else {
                NewsView(alertFromSplashView: $alert)
            }
        }
        .onAppear {
            user = userQuery.first ?? nil
            Task {
                if await getConfig() {
                    if await getUser() {
                        await getNews()
                        await getMessages()
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    self.finished = true
                }
            }
        }
        .onOpenURL { url in
            guard url.scheme == "swiftnews" else {
                return
            }
            let newsData = url.absoluteString.replacingOccurrences(of: "swiftnews://", with: "")
            guard newsData.count == 97 else {
                return
            }
            Task {
                do {
                    let openedNews: NewsSchema = try await APIManager.shared.getData(from: "sharednews/" + newsData)
                    sharedNews = NewsModel(url: openedNews.url,
                                           category: openedNews.category,
                                           date: openedNews.date,
                                           title: openedNews.title,
                                           content: openedNews.content)
                    isSheetVisible = true
                } catch {
                    alert.toggle()
                }
            }
        }
        .sheet(isPresented: $isSheetVisible) {
            SharedNewsView(news: $sharedNews)
        }
    }
    
    func getConfig() async -> Bool{
        var configSchema: ConfigSchema
        do {
            configSchema = try await APIManager.shared.getData(from: "config")
        }
        catch {
            alert = true
            return true
        }
        
        var locations: [String: [String]] = [:]
        for location in configSchema.locations {
            locations["\(location.region) \(location.language)".uppercased()] = location.categories
        }
        
        config = ConfigModel(
            times: configSchema.times,
            locations: locations
        )
        
        do {
            try modelContext.delete(model: ConfigModel.self)
            modelContext.insert(config!)
            try modelContext.save()
        }
        catch {
            alert = true
            return true
        }
        return true
    }
    
    func getUser() async -> Bool {
        var userid: String
        if user == nil {
            do {
                let tmp: UserSchema = try await APIManager.shared.getData(from: "user")
                userid = tmp.id
            }
            catch {
                // TODO: alert that couldn't get a username
                alert = true
                return true
            }
        }
        else {
            userid = self.user!.id
        }
        
        let location = user?.location ?? "PL PL"
        
        var categories: [String: Int] = [:]
        if let configCategories = config?.locations[location] {
            for category in configCategories {
                categories[category] = user?.categories[category] ?? 10
            }
        }
        
        user = UserModel(
            id: userid,
            time: user?.time ?? 10,
            location: location,
            categories: categories
        )
        
        do {
            try modelContext.delete(model: UserModel.self)
            modelContext.insert(user!)
            try modelContext.save()
        }
        catch {
            alert = true
            return true
        }
        return true
    }
    
    func getNews() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let today: String = formatter.string(from: Date())
        if newsQuery.first?.date ?? "" == today {
            return
        }
        
        var newsSchemas: [NewsSchema] = []
        do {
            let dataToSend = NewsPostSchema(
                user: user!.id,
                time: user!.time,
                location: user!.location,
                categories: user!.categories
            )
            newsSchemas = try await APIManager.shared.postData(data: dataToSend, to: "newsfeed")
        }
        catch {
            alert = true
            return
        }
        
        do {
            try modelContext.delete(model: NewsModel.self, where: #Predicate { $0.saved == false })
            for news in newsSchemas {
                let newsModel = NewsModel(
                    url: news.url,
                    category: news.category,
                    date: news.date,
                    title: news.title,
                    content: news.content,
                    saved: false
                )
                modelContext.insert(newsModel)
            }
            try modelContext.save()
        }
        catch {
            alert = true
            return
        }
    }
    
    func getMessages() async {
        let messageSchemas: [MessageSchema]
        do {
            messageSchemas = try await APIManager.shared.getData(from: "support/\(user!.id)")
        }
        catch {
            alert = true
            return
        }
        
        do {
            for message in messageSchemas {
                let messageModel = MessageModel(
                    id: message.id,
                    message: message.response
                )
                modelContext.insert(messageModel)
            }
            try modelContext.save()
        }
        catch {
            alert = true
            return
        }
    }
}
