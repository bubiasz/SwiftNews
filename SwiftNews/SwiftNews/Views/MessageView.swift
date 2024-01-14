//
//  SwiftNews
//

import SwiftUI
import SwiftData


struct SupportMessage: Codable {
    let user: String
    let title: String
    let message: String
}


struct MessageView: View {
    @State private var title = ""
    @State private var content = "";
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @FocusState private var isFocusedTitle: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.modelContext) private var modelContext
    @Query var user: [UserModel]
    
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
    
    func send() -> Void {
        if(title.isEmpty) {
            alertMessage = "Can't send a message without a title!"
        }
        else if(content.isEmpty) {
            alertMessage = "Can't send an empty message!"
        }
        else {
            Task {
                do {
                    let responseData: [String: String] = try await APIManager.shared.getData(from: "support/\(user[0].id)")
                    print("Response Data: \(responseData)")
                } catch {
                    // Obsługa błędu
                    print("Error: \(error)")
                    let emptyResponse: [String: String] = [:] // Pusta tablica
                    print("Empty Response Data: \(emptyResponse)")
                    alertMessage = "Error sending your message"
                }
            }

            Task {
                let dataToSend = SupportMessage(
                    user: "\(user[0].id)",
                    title: title,
                    message: content
                )
                let responseData: [String: String] = try await APIManager.shared.postData(data: dataToSend, to: "support")
                print("Response Data: \(responseData)")
            }
            
            alertMessage = "Message sent successfully!"
        }
        showAlert = true
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    TextField("Enter a title of your message", text: $title, axis: .vertical)
                        .focused($isFocusedTitle)
                        .submitLabel(.done)
                        .onSubmit {
                            hideKeyboard()
                        }
                        .lineLimit(2)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8.0)
                        .padding()
                    
                    TextField("Enter content of your message", text: $content, axis: .vertical)
                        .submitLabel(.done)
                        .lineLimit(15...15)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8.0)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    Text("Your message will be sent with your unique ID, so we will be able to contact you afterwards")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.foreground.opacity(0.5))
                        .padding()
                }
                
                Spacer()
                
                Button(action: send) {
                    HStack {
                        Image(systemName: "paperplane")
                        Text("Send")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(alertMessage),
                        dismissButton: Alert.Button.default(
                            Text("OK"),
                            action: {
                                resetData()
                            })
                    )
                }
                .foregroundColor(Color.background)
                .buttonStyle(BorderlessButtonStyle())
                .background(Color.foreground)
                .cornerRadius(8.0)
                .navigationBarTitle("Message us", displayMode: .inline)
                .padding(.vertical, 40)
                .padding(.horizontal, 50)
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

//#Preview {
//    MessageView()
//}
