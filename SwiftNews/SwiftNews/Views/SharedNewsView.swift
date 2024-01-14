//
//  SharedNewsView.swift
//  SwiftNews
//

import Foundation
import SwiftData
import SwiftUI

struct SharedNewsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Query private var userQuery: [UserModel]
    
    @Binding var news: NewsModel?
    
    @State private var isTitleExpanded: Bool = false
    @State private var isContentExpanded: Bool = false
    
    @State private var link: String? = nil
    @State private var alert: Bool = false
    
    var body: some View {
        ScrollView {
            Text("\(news!.title)")
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
            
            Text("\(news!.content)")
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
                    handleSave()
                }) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(Color("foreground"))
                }
                
                Spacer()
                
                Button(action: {
                   handleUrl()
                }) {
                    Image(systemName: "globe")
                        .foregroundColor(Color("foreground"))
                }

                Spacer()
                    
                Button(action: {
                    handleShare()
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
        .alert(isPresented: $alert) {
            Alert(title: Text("Share your news"), message: Text("Would you like to copy the link to your shared news into your clipboard?"), primaryButton: .default(Text("Copy")) {
                UIPasteboard.general.string = link
            }, secondaryButton: .cancel())
        }
    }
    
    func handleUrl() {
        if UIApplication.shared.canOpenURL(URL(string: news!.url)!) {
            UIApplication.shared.open(URL(string: news!.url)!, options: [:], completionHandler: nil)
        }
    }
    
    func handleSave() {
        if userQuery.first!.categories[news!.category] != nil {
            userQuery.first!.categories[news!.category]! += 50
        }
        
        modelContext.insert(news!)
        news!.saved = true
        try? modelContext.save()
        
        presentationMode.wrappedValue.dismiss()
    }
    
    func handleShare() {
        let data = SharedPostSchema(
            user: userQuery.first!.id,
            url: news!.url,
            date: news!.date,
            title: news!.title,
            content: news!.content,
            category: news!.category
        )
        
        Task {
            do {
                let response: [String: String] = try await APIManager.shared.postData(data: data, to: "sharednews")
                link = response["url"]!
            }
            catch {
                // TODO: error
            }
        }
        alert.toggle()
    }
}
