//
//  SavedNewsView.swift
//  SwiftNews
//

import Foundation
import SwiftUI
import SwiftData

struct SavedView: View {
    // Database connection
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<NewsModel> { $0.saved == true }) var newsQuery: [NewsModel]
    
    // View implementation
    var body: some View {
        NavigationStack {
            VStack {
                if newsQuery.count == 0 {
                    Text("You didn't save any news yet.")
                }
                else {
                    List {
                        ForEach(newsQuery, id: \.title) { item in
                            NavigationLink(destination: SingleNewsView(news: item)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    
                                    Text(item.title)
                                        .font(.headline)
                                    
                                    Text(item.date)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
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
