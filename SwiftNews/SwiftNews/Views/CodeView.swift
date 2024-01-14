//
//  CodeView.swift
//  SwiftNews
//

import Foundation
import SwiftData
import SwiftUI

struct CodeView: View {
    // Database connection
    @Environment(\.modelContext) private var modelContext
    @Query private var userQuery: [UserModel]
    
    // QR code image
    @State private var uiImage: UIImage? = nil
    
    @State private var showAlert: Bool = false
    @State private var isSheetVisible: Bool = false
    
    // View implementation
    var body: some View {
        VStack {
            if let uiImage = self.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
            } else {
                Text("Loading...")
                    .frame(width: 200)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
            }
            
            Text("Scan this QR code in order to transfer your data to another device")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray)
                .font(.caption)
                .padding()
            
            Button(action: {
                isSheetVisible.toggle()
            }, label: {
                HStack {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan QR code")
                }
                .padding()
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .background(Color.foreground)
                .foregroundColor(Color.background)
                .cornerRadius(8)
            })
        }
        .padding(50)
        .navigationBarTitle("Transfer", displayMode: .inline)
        .onAppear(perform: loadImageFromURL)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Something went wrong"), message: Text("Please check your internet connection and try again later"), dismissButton: .default(Text("Continue")))
        }
        .sheet(isPresented: $isSheetVisible) {
            ScannerView()
        }
    }

    func loadImageFromURL() {
        Task {
            do {
                let dataToSend = CodeSchema(
                    user: userQuery.first!.id,
                    time: userQuery.first!.time,
                    location: userQuery.first!.location,
                    categories: userQuery.first!.categories
                )
                let responseData: [String: String] = try await APIManager.shared.postData(data: dataToSend, to: "qrcode")
                
                guard let url = URL(string: responseData["url"]!) else { return }

                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.uiImage = UIImage(data: data)
                        }
                    }
                }.resume()
            } catch {
                self.showAlert.toggle()
                return
            }
        }
    }
}
