//
//  SwiftNews
//

import SwiftUI
import SwiftData


struct SavedNewsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(filter: #Predicate<NewsModel> { $0.saved == true }) var savedNews: [NewsModel]
    
    var body: some View {
        NavigationStack {
            VStack {
                if savedNews.count == 0 {
                    Text("You didn't save any news yet.")
                }
                else {
                    List {
                        ForEach(savedNews, id: \.title) { item in
                            HStack {
                                NavigationLink(destination: SingleNewsView(news: item)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        
                                        Text(item.title)
                                            .font(.headline)
                                        
                                        Text(item.date)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
//                                    Spacer()
//                                    
//                                    Image(systemName: "chevron.right")
//                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                
            }
            .navigationBarTitle("Saved news", displayMode: .inline)
        }
    }
}

//#Preview {
//    SavedNewsView()
//}
