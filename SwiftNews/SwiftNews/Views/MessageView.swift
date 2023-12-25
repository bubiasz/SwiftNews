//
//  SwiftNews
//

import SwiftUI


struct MessageView: View {
    @State private var title = ""
    @State private var content = "";
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @FocusState private var isFocusedTitle: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
    
    func send() -> Void {
        print(title + content)
        if(title.isEmpty) {
            alertMessage = "Can't send a message without a title!"
        }
        else if(content.isEmpty) {
            alertMessage = "Can't send an empty message!"
        }
        else {
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
                                content = ""
                                title = ""
                                presentationMode.wrappedValue.dismiss()
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
