//
//  SwiftNews
//

import SwiftData
import SwiftUI


struct SplashView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var userQuery: [UserModel]
    @Query(filter: #Predicate<NewsModel> { $0.saved == false }) private var newsQuery: [NewsModel]
    
    @State private var user: UserModel?
    @State private var config: ConfigModel?
    
    @State private var isActive: Bool = false
    @State private var opacity: Double = 1.0
    @State private var state: RotationState = .min
    
    var body: some View {
        ZStack {
            if self.isActive {
                NewsView()
            }
            else {
                VStack {
                    Image(uiImage: UIImage(named: "AppIcon")!)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8.0)
                        .frame(width: 150, height: 150)
                        .rotationEffect(state == .max ? .degrees(-15) : .degrees(15) , anchor: .top)
                        .onAppear{
                            let baseAnimation = Animation.easeInOut(duration: 1)
                            let repeated = baseAnimation.repeatForever(autoreverses: true)
                            withAnimation(repeated) {
                                switch state {
                                case .max:
                                    state = .min
                                case .min:
                                    state = .max
                                }
                            }
                        }
                        .padding(.vertical)
                    
                    Text("SwiftNews")
                        .font(.title)
                        .bold()
                    
                }
                .padding()
            }
        }
        .onAppear {
            user = userQuery.first ?? nil
            
            Task {
                await fetchAPI()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    self.isActive = true
                }
            }
            
        }
    }
    
    func fetchAPI() async {
        if await getConfig() {
            if await getUser() {
                _ = await getNews()
            }
        }
    }
    
    func getUser() async -> Bool {
        var userid: String
        if user == nil {
            do {
                let tmp: UserSchema = try await APIManager.shared.getData(from: "user")
                userid = tmp.uniqueId
            }
            catch {
                // TODO: alert that couldn't get a username
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
                categories[category] = user?.categories?[category] ?? 1
            }
        }
        
        user = UserModel(
            id: userid,
            time: user?.time ?? 10,
            location: location,
            categories: [
                "business": 100,
                "sport": 0
            ]
        )
        
        do {
            try modelContext.delete(model: UserModel.self)
            modelContext.insert(user!)
            try modelContext.save()
        }
        catch {
            // TODO: alert that couldn't update user
            return true
        }
        return true
    }
    
    func getConfig() async -> Bool{
        var configSchema: ConfigSchema
        do {
            configSchema = try await APIManager.shared.getData(from: "config")
        }
        catch {
            // TODO: alert that couldn't update config
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
            // TODO: alert that couldn't update config
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
            let dataToSend = NewsfeedSchema(
                user: user!.id,
                time: user!.time,
                location: user!.location,
                categories: user!.categories!
            )
            newsSchemas = try await APIManager.shared.postData(data: dataToSend, to: "newsfeed")
        }
        catch {
            // TODO: alert couldn't load news
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
            // TODO: alert that couldn't load news
            return
        }
    }
}

enum RotationState: Int {
    case max
    case min
}

#Preview {
    SplashView()
        .modelContainer(for: [NewsModel.self, UserModel.self, ConfigModel.self])
}
