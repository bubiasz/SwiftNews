//
//  SwiftNews
//

import SwiftData
import SwiftUI


struct NewsView: View {
    
    @State var isTitleExpanded: Bool = false
    @State var isContentExpanded: Bool = false
    
    @State private var articleOffset: CGFloat = 0
    @State private var isSwiped = false
    
    @Environment(\.modelContext) private var modelContext
    
    @Query var news: [NewsModel]
    
    @State var index: Int = 0
    
    @Query var categories: [CategoryModel]
    
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
                
                ScrollView {
                    Text("\(news[index].title)")
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
                    
                    Text("\(news[index].content)")
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
                            handleLike(news: news[index], swiped: false)
                        }) {
                            Image(systemName: "hand.thumbsup.fill")
                                .foregroundColor(Color("foreground"))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            handleDislike(news: news[index], swiped: false)
                        }) {
                            Image(systemName: "hand.thumbsdown.fill")
                                .foregroundColor(Color("foreground"))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            handleSave(news: news[index])
                        }) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(Color("foreground"))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            handleUrl(news: news[index])
                        }) {
                            Image(systemName: "globe")
                                .foregroundColor(Color("foreground"))
                        }

                        Spacer()
                        
                        Button(action: {
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
                .gesture(DragGesture(minimumDistance: 100.0, coordinateSpace: .local)
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
                                switch(value.translation.width, value.translation.height) {
                                    case (...0, -30...30):  handleDislike(news: news[index], swiped: true)
                                    case (0..., -30...30):  handleLike(news: news[index], swiped: true)
                                    default: do {}
                                }
                                
                                let customAnimation = Animation.timingCurve(0.2, 1, 1, 1, duration: 0.75)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(customAnimation) {
                                        resetValues()
                                    }
                                }
                            } else {
                                articleOffset = 0
                            }
                        }
                    }
                )
            }
            .padding()
        }
    }
    
    func resetValues() -> Void {
        isContentExpanded = false
        isTitleExpanded = false
        articleOffset = 0
        isSwiped = false
        index += 1
    }
    
    func handleDislike(news: NewsModel, swiped: Bool) -> Void {
        if let matchingCategory = categories.first(where: { $0.name == news.category }) {
            if matchingCategory.value != 0 {
                matchingCategory.value -= 1
            }
            
            try? modelContext.save()
        }
        
        if !swiped {
            resetValues()
        }
    }
    
    func handleLike(news: NewsModel, swiped: Bool) -> Void {
        if let matchingCategory = categories.first(where: { $0.name == news.category }) {
            matchingCategory.value += 1
            resetValues()

            try? modelContext.save()
        }
        
        if !swiped {
            resetValues()
        }
    }
    
    func handleSave(news: NewsModel) -> Void {
        news.saved.toggle()
        try? modelContext.save()
    }
    
    func handleUrl(news: NewsModel) -> Void {
        if UIApplication.shared.canOpenURL(URL(string: news.url)!) {
            UIApplication.shared.open(URL(string: news.url)!, options: [:], completionHandler: nil)
        }
    }
}

//#Preview {
//    NewsView()
//}
