//
//  SingleNewsView.swift
//  SwiftNews
//

import Foundation
import SwiftUI
import SwiftData

struct SingleNewsView: View {
    // Database related
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @Bindable var news: NewsModel
    
    // News display related variables
    @State private var isTitleExpanded: Bool = false
    @State private var isContentExpanded: Bool = false
    
    // View implementation
    var body: some View {
        ScrollView {
            Text("\(news.title)")
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
            
            Text("\(news.content)")
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
                    handleUnsave(news: news)
                }) {
                    Image(systemName: "heart.slash.fill")
                        .foregroundColor(Color("foreground"))
                }
                
                Spacer()
                
                Button(action: {
                    handleUrl(news: news)
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
        .padding()
        .frame(minHeight: 595, maxHeight: 595)
    }
    
    func handleUnsave(news: NewsModel) {
        modelContext.delete(news)
        presentationMode.wrappedValue.dismiss()
    }
    
    func handleUrl(news: NewsModel) {
        if UIApplication.shared.canOpenURL(URL(string: news.url)!) {
            UIApplication.shared.open(URL(string: news.url)!, options: [:], completionHandler: nil)
        }
    }
}
