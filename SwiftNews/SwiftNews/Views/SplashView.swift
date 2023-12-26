//
//  SwiftNews
//

import SwiftData
import SwiftUI


struct SplashView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query var user: [UserModel]
    @Query(filter: #Predicate<NewsModel> { $0.saved == false }) var news: [NewsModel]
    @Query var categories: [CategoryModel]
    
    
    @Query(filter: #Predicate<LocationModel> { $0.region == "gb" }) var location: [LocationModel]

    
    @State var isActive: Bool = false
    @State var opacity: Double = 1.0
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
            do {
                try modelContext.delete(model: NewsModel.self)
            }
            catch {}
            
            if user.count == 0 {
                getUser()
            }
            getConfig()
            getNews()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    self.isActive = true
                    
                    for category in location[0].categories! {
                        let categoryModel = CategoryModel(name: category, value: 0)
                        modelContext.insert(categoryModel)
                    }
                    
//                    for category in categories {
//                        print("\(category.name): \(category.value)")
//                    }
                    
                    for category in categories {
                        if !(location[0].categories ?? []).contains(category.name) {
                            
                            if let index = categories.firstIndex(of: category) {
                                print("Removed \(categories[index].name)")
                                modelContext.delete(categories[index])
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    func getUser() {
        Task {
            do {
                let user: UserSchema = try await APIManager.shared.getData(from: "user")
                
                let userModel = UserModel(id: user.uniqueId)
                modelContext.insert(userModel)
            }
            catch {
                print("Error: \(error)")
            }
        }
    }
    
    func getConfig() {
        Task {
            do {
                let languages: [ConfigSchema] = try await APIManager.shared.getData(from: "config")
                
                for language in languages {
                    let configModel = LocationModel(
                        language: language.language,
                        region: language.region,
                        categories: language.categories
                    )
                    modelContext.insert(configModel)
                }
            }
            catch {
                print("Error: \(error)")
            }
        }
    }
    
    func getNews() {
        Task {
            do {
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
            }
            catch {
                print("Error: \(error)")
            }
        }
    }
}

enum RotationState: Int {
    case max
    case min
}

#Preview {
    SplashView()
        .modelContainer(for: [LocationModel.self, NewsModel.self, UserModel.self, CategoryModel.self])
}
