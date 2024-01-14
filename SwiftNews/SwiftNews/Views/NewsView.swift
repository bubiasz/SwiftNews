//
//  NewsView.swift
//  SwiftNews
//

import Foundation
import SwiftData
import SwiftUI

struct NewsView: View {
    // Database connection
    @Environment(\.modelContext) private var modelContext
    @Query private var userQuery: [UserModel]
    @Query(filter: #Predicate<NewsModel> { $0.saved == false }) private var newsQuery: [NewsModel]
    @Binding var alertFromSplashView: Bool
    
    // news handlers
    @State private var index: Int = 0
    @State private var isSwiped: Bool = false
    @State private var articleOffset: CGFloat = 0
    @State private var isTitleExpanded: Bool = false
    @State private var isContentExpanded: Bool = false
    
    // alert variables savednews
    @State private var link: String? = nil
    @State private var alert: Bool = false
    @State private var activeAlert: ActiveAlert = .error
    
    private enum ActiveAlert: String {
        case error, done
    }
    
    // View implementation
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(Color("foreground"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                Spacer()
                
                if newsQuery.count == 0 {
                    Text("Comeback tomorrow for more content!")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("You've already browsed everything we've prepared for you today")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    Spacer()
                }
                else {
                    ScrollView {
                        Text("\(newsQuery[0].title)")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(isTitleExpanded ? nil : 1)
                            .onTapGesture {
                                withAnimation {
                                    isTitleExpanded.toggle()
                                }
                            }
                        
                        Text("\(newsQuery[0].content)")
                            .padding(.bottom)
                            .lineLimit(isContentExpanded ? nil : 20)
                            .onTapGesture {
                                withAnimation {
                                    isContentExpanded.toggle()
                                }
                            }
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                handleLike(news: newsQuery[0], swiped: false)
                            }) {
                                Image(systemName: "hand.thumbsup.fill")
                                    .foregroundColor(Color("foreground"))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                handleDislike(news: newsQuery[0], swiped: false)
                            }) {
                                Image(systemName: "hand.thumbsdown.fill")
                                    .foregroundColor(Color("foreground"))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                handleSave(news: newsQuery[0])
                            }) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(Color("foreground"))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                handleUrl(news: newsQuery[0])
                            }) {
                                Image(systemName: "globe")
                                    .foregroundColor(Color("foreground"))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                handleShare(news: newsQuery.first!)
                            }) {
                                Image(systemName: "square.and.arrow.up.fill")
                                    .foregroundColor(Color("foreground"))
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                    .padding(.vertical)
                    .frame(minHeight: 595, maxHeight: 595)
                    .offset(x: articleOffset)
                    .opacity(isSwiped ? 0 : 1)
                    .gesture(DragGesture(minimumDistance: 200.0, coordinateSpace: .local)
                        .onChanged {
                            value in
                            withAnimation {
                                articleOffset = value.translation.width
                            }
                        }
                        .onEnded { value in
                            withAnimation {
                                let screenWidth = UIScreen.main.bounds.width
                                if abs(articleOffset) > screenWidth * 0.7 {
                                    articleOffset = articleOffset > 0 ? screenWidth : -screenWidth
                                    isSwiped = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        articleOffset = articleOffset > 0 ? -screenWidth : +screenWidth
                                    }
                                    switch(value.translation.width, value.translation.height) {
                                    case (...0, -30...30):  handleDislike(news: newsQuery[0], swiped: true)
                                    case (0..., -30...30):  handleLike(news: newsQuery[0], swiped: true)
                                    default: do {}
                                    }
                                    
                                    let customAnimation = Animation.timingCurve(0.2, 1, 1, 1, duration: 0.75)
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(customAnimation) {
                                            resetValues()
                                        }
                                    }
                                }
                                else {
                                    articleOffset = 0
                                }
                            }
                        }
                    )
                }
            }
            .padding()
        }
        .alert(isPresented: $alert) {
            switch activeAlert {
            case .error:
                return Alert(title: Text("Encountered a problem"), message: Text("Problem with handling response from API"), dismissButton: .default(Text("Continue")))
            case .done:
                return Alert(title: Text("Share your news"), message: Text("Would you like to copy the link to your shared news into your clipboard?"), primaryButton: .default(Text("Copy")) {
                    UIPasteboard.general.string = link
                }, secondaryButton: .cancel())
            }
        }
        .onAppear {
            if alertFromSplashView == true {
                activeAlert = .error
                alert = true
            }
        }
    }
    
    func resetValues() -> Void {
        isContentExpanded = false
        isTitleExpanded = false
        articleOffset = 0
        isSwiped = false
    }
    
    func handleDislike(news: NewsModel, swiped: Bool) {
        if let value = userQuery.first!.categories[news.category] {
            if value != 10 {
                userQuery.first!.categories[news.category]! -= 10
                try? modelContext.save()
            }
        }
        
        if !swiped {
            resetValues()
        }
        modelContext.delete(news)
    }
    
    func handleLike(news: NewsModel, swiped: Bool) {
        if userQuery.first!.categories[news.category] != nil {
            userQuery.first!.categories[news.category]! += 10
            try? modelContext.save()
        }
        
        if !swiped {
            resetValues()
        }
        modelContext.delete(news)
    }
    
    func handleSave(news: NewsModel) {
        if userQuery.first!.categories[news.category] != nil {
            userQuery.first!.categories[news.category]! += 50
        }
        
        news.saved.toggle()
        try? modelContext.save()
        
    }
    
    func handleShare(news: NewsModel) {
        let data = SharedPostSchema(
            user: userQuery.first!.id,
            url: news.url,
            date: news.date,
            title: news.title,
            content: news.content,
            category: news.category
        )
        
        Task {
            do {
                let response: [String: String] = try await APIManager.shared.postData(data: data, to: "sharednews")
                link = response["url"]!
                activeAlert = .done
            }
            catch {
                activeAlert = .error
            }
        }
        alert.toggle()
    }
    
    func handleUrl(news: NewsModel) {
        if UIApplication.shared.canOpenURL(URL(string: news.url)!) {
            UIApplication.shared.open(URL(string: news.url)!, options: [:], completionHandler: nil)
        }
    }
}
