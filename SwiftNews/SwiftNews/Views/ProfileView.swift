//
//  SwiftNews
//

import SwiftData
import SwiftUI


struct CustomButton: View {
    var icon: String
    var text: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
            
            Text(text)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .foregroundStyle(Color.background)
        .background(Color.foreground)
        .cornerRadius(8)
    }
}

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    
    let timeList: [Int] = [10, 20, 30]
    @State private var selectedTime: Int = 10
    
    @Query var locationList: [LocationModel]
    @State private var selectedLocation: LocationModel?
    @State private var location: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        NavigationLink(destination: SavedNewsView())  {
                            CustomButton(icon: "book", text: "Saved news")
                        }
                        
                        NavigationLink(destination: PreferencesView())  {
                            CustomButton(icon: "chart.pie", text: "Preferences")
                        }
                    }
                    
                    HStack(spacing: 20) {
                        NavigationLink(destination: CodeView())  {
                            CustomButton(icon: "qrcode", text: "Transfer")
                        }
                        
                        NavigationLink(destination: MessageView())  {
                            CustomButton(icon: "envelope.badge", text: "Message us")
                        }
                    }
                }
                .padding(.vertical)
                
                VStack(alignment: .leading, content:  {
                    Text("News number daily")
                        .font(.headline)
                    
                    Picker("Select a number", selection: $selectedTime) {
                        ForEach(timeList, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.segmented)
                })
                .padding(.vertical)
                
                VStack(alignment: .leading, content: {
                    Picker(selection: $selectedLocation, label: 
                        Text("Your country & language")
                            .foregroundStyle(Color.foreground)
                            .font(.headline)) {
                            ForEach(locationList, id: \.self) { location in
                                Text("\(location.region), \(location.language)")
                            }
                        }
                        .pickerStyle(.navigationLink)
                    
                    HStack {
                        Text("Find my location")
                        Image(systemName: "location.fill.viewfinder")
                    }
                    .foregroundStyle(Color.blue)
                    .onTapGesture {
                        let userLocale = Locale.current
                        location = userLocale.identifier
                        print(location!)
                    }
                })
                .padding(.vertical)

                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//#Preview {
//    ProfileView()
//        .modelContainer(for: [UserModel.self, LocationModel.self, NewsModel.self])
//}
