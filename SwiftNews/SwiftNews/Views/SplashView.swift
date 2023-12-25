//
//  SwiftNews
//

import SwiftData
import SwiftUI


struct SplashView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State var isActive: Bool = false
    @State var opacity: Double = 1.0
    @State private var drawingWidth = false
    
    var body: some View {
        ZStack {
            if self.isActive {
                NewsView()
            }
            else {
                VStack {
                    Text("SwiftNews")
                        .font(.title)
                        .bold()
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(.systemGray6))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.black)
                            .frame(width: drawingWidth ? 250 : 0, alignment: .leading)
                            .animation(.easeInOut(duration: 3), value: drawingWidth)
                    }
                    .frame(width: 250, height: 12)
                    .onAppear {
                        drawingWidth.toggle()
                    }
                    
                }
                .padding()
            }
        }
        .onAppear {
            getUser()
            getConfig()
            getNews()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
    
    func getUser() {
        Task {
            do {
                print("User")
                let user: UserSchema = try await APIManager.shared.getData(from: "user")
                
                let userModel = UserModel(id: user.uniqueId)
                modelContext.insert(userModel)
                
                print("User Success")
            }
            catch {
                print("Error: \(error)")
            }
        }
    }
    
    func getConfig() {
        Task {
            do {
                print("Config")
                let languages: [ConfigSchema] = try await APIManager.shared.getData(from: "config")
                print("Config completed")
                
                for language in languages {
                    let configModel = LocationModel(
                        language: language.language,
                        region: language.region,
                        categories: language.categories
                    )
                    modelContext.insert(configModel)
                }
                
                print("Config Success")
            }
            catch {
                print("Error: \(error)")
            }
        }
    }
    
    func getNews() {
        Task {
            do {
                print("News")
                let dataToSend = NewsfeedSchema(
                    user: "kqaxIkZcKKHOcIboYMeZLHBXUdgalSHH",
                    time: 10,
                    region: "pl",
                    language: "pl",
                    categories: [
                        "business": 100,
                        "sports": 0,
                        "country": 0,
                    ]
                )
                let newsList: [NewsSchema] = try await APIManager.shared.postData(data: dataToSend, to: "newsfeed")
                
                for news in newsList {
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
                
                print("News Success")
            }
            catch {
                print("Error: \(error)")
            }
        }
    }
}

//#Preview {
//    SplashView()
//        .modelContainer(for: [LocationModel.self, NewsModel.self, UserModel.self])
//}
