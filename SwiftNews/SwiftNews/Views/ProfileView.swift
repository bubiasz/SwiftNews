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
    @Query private var user: [UserModel]
    @Query private var config: [ConfigModel]
    
    @State private var times: [Int] = []
    @State private var locations: [String] = []
    
    @State private var timePick: Int = 0
    @State private var locationPick: String = ""
    
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
                    
                    Picker("Select a number", selection: $timePick) {
                        ForEach(times, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.segmented)
                })
                .padding(.vertical)
                        
                VStack(alignment: .leading, content: {
                    HStack {
                        Text("Your country & language")
                            .font(.headline)
                        Spacer()
                        Picker("Select location", selection: $locationPick) {
                            ForEach(locations, id: \.self) { location in
                                Text("\(location)")
                            }
                        }
                    }
                    
                    HStack {
                        Text("Find me")
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
            .onAppear {
                times = config.first!.times
                locations = Array((config.first?.locations.keys)!)
                timePick = user.first!.time
                locationPick = user.first!.location
            }
        }
    }
}

//#Preview {
//    ProfileView()
//        .modelContainer(for: [ConfigModel.self, UserModel.self])
//}
