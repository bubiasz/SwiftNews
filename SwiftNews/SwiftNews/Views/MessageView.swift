//
//  MessageView.swift
//  SwiftNews
//

import Foundation
import SwiftData
import SwiftUI

struct MessageView: View {
    // Database connection
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    @Query private var userQuery: [UserModel]
    @FocusState private var isFocusedTitle: Bool
    
    // message content
    @State private var title: String = ""
    @State private var content: String = ""
    
    // alert variables
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var errorOccured: Bool = false
    
    // View implementation
    var body: some View {
        VStack {
            ScrollView {
                TextField("Enter a title of your message", text: $title, axis: .vertical)
                    .focused($isFocusedTitle)
                    .submitLabel(.done)
                    .onSubmit {
                        hideKeyboard()
                    }
                    .lineLimit(1)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding()
                    .padding(.top, 10)
                
                TextField("Enter content of your message", text: $content, axis: .vertical)
                    .submitLabel(.done)
                    .lineLimit(14...14)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.horizontal)
            }
            
            Text("Your message will be sent with your unique ID, so we will be able to contact you afterwards")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray)
                .font(.caption)
                .padding(.vertical, 10)
                .padding(.horizontal, 60)
            
            Button(action: sendMessage) {
                HStack {
                    Image(systemName: "paperplane")
                    Text("Send")
                }
                .padding()
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .background(Color.foreground)
                .foregroundStyle(Color.background)
                .cornerRadius(8)
            }
            .padding(.bottom, 50)
            .padding(.horizontal, 50)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(errorOccured ? "Something went wrong" : "Success"),
                    message: Text(alertMessage),
                    dismissButton: Alert.Button.default(
                        Text("OK"),
                        action: {
                            resetData()
                        })
                )
            }
        }
        .navigationBarTitle("Message us", displayMode: .inline)
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
    
    func resetData() -> Void {
        if !title.isEmpty && !content.isEmpty {
            content = ""
            title = ""
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func sendMessage() -> Void {
        if(title.isEmpty) {
            errorOccured = true
            alertMessage = "Can't send a message without a title!"
        }
        else if(content.isEmpty) {
            errorOccured = true
            alertMessage = "Can't send an empty message!"
        }
        else {
            Task {
                do {
                    let dataToSend = MessagePostSchema(
                        user: userQuery.first!.id,
                        title: title,
                        message: content
                    )
                    
                    let responseData: [String: String] = try await APIManager.shared.postData(data: dataToSend, to: "support")
                    
                    errorOccured = false
                    alertMessage = responseData["message"]!
                }
                catch {
                    errorOccured = true
                    alertMessage = "Could not send your message"
                }
            }
        }
        showAlert = true
    }
}
