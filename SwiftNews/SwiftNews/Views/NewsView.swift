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
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(Color("foreground"))
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
                }
                
                Spacer()
                
                ScrollView {
                    Text("\(news[index].title)")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
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
                        
                        Image(systemName: "hand.thumbsup.fill")
                        
                        Spacer()
                        
                        Image(systemName: "hand.thumbsdown.fill")
                        
                        Spacer()
                        
                        Image(systemName: "heart.fill")
                        
                        Spacer()
                        
                        Button(action: {
                            if UIApplication.shared.canOpenURL(URL(string: news[index].url)!) {
                                UIApplication.shared.open(URL(string: news[index].url)!, options: [:], completionHandler: nil)
                            }
                            else {
                                print("error opening site")
                            }
                        }) {
                            Image(systemName: "globe")
                                .foregroundColor(Color("foreground"))
                        }

                        Spacer()
                        
                        Image(systemName: "square.and.arrow.up.fill")
                        
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
                                    case (...0, -30...30):  print("left swipe")
                                    case (0..., -30...30):  print("right swipe")
                                    default:  print("no clue")
                                }
                                
                                
                                let customAnimation = Animation.timingCurve(0.2, 1, 1, 1, duration: 0.75)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(customAnimation) {
                                        isContentExpanded = false
                                        isTitleExpanded = false
                                        articleOffset = 0
                                        isSwiped = false
                                        index += 1
                                        
//                                        if index >= news.count {
//                                            index = 0
//                                        }
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
    
}

//#Preview {
//    NewsView()
//}
