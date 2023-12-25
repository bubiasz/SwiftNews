//
//  SwiftNews
//

import SwiftUI


struct CodeView: View {
    
    @State private var uiImage: UIImage? = nil
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                } else {
                    Text("Loading...")
                }
                Text("Scan this QR code in order to transfer your data to another device")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .padding()
                Spacer()
                Button(action: {
                    // Action
                }) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder") // Replace "qrcode.viewfinder" with your QRCode icon name
                            .font(.system(size: 20))
                            .foregroundColor(Color.background)
                        
                        Text("Scan QR code")
                            .foregroundColor(Color.background)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        
                    }
                    .padding()
                    .background(Color.foreground)
                    .cornerRadius(8)
                    
                }
                .padding()
            }
            .onAppear(perform: loadImageFromURL)
            .padding()
            .navigationBarTitle("Transfer data", displayMode: .inline)
        }
        .padding()
    }

    func loadImageFromURL() {
        Task {
            do {
                let dataToSend = CodeSchema(
                    user: "kqaxIkZcKKHOcIboYMeZLHBXUdgalSHH",
                    time: 10,
                    region: "pl",
                    language: "pl",
                    categories: [
                        "business": 100,
                        "sports": 0,
                        "country": 0,
                    ]
                )
                let responseData: [String: String] = try await APIManager.shared.postData(data: dataToSend, to: "qrcode")
                
                guard let url = URL(string: responseData["qr"]!) else { return }

                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.uiImage = UIImage(data: data)
                        }
                    }
                }.resume()
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

//#Preview {
//    CodeView()
//}
