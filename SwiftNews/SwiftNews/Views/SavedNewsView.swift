//
//  SwiftNews
//

import SwiftUI
import SwiftData


struct SavedNewsView: View {
//    @State private var savedNews: [(title: String, date: String)] = [
//            ("Title 1", "November 1, 2023"),
//            ("Title 2", "December 5, 2023"),
//            ("Title 3", "December 8, 2023"),
//            ("Title 4", "December 16, 2023"),
//            ("Title 5", "December 24, 2023"),
//            ("Title 6", "December 31, 2023"),
//            ("Title 7", "December 31, 2023"),
//            ("Title 8", "December 31, 2023"),
//            ("Title 9", "December 31, 2023"),
//            ("Title 9", "December 31, 2023"),
//            ("Title 9", "December 31, 2023"),
//        ]
    
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
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.headline)
                                    
                                    Text(item.date)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
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
