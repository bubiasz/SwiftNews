//
//  ProfileView.swift
//  SwiftNews
//

import Foundation
import SwiftData
import SwiftUI

struct SupportMessageView: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var supportMessage: MessageModel
    
    var body: some View {
        Text(supportMessage.message)
            .font(.subheadline)
            .onDisappear {
                modelContext.delete(supportMessage)
                try? modelContext.save()
            }
    }
}

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
    // Database connection
    @Environment(\.modelContext) private var modelContext
    @Query private var userQuery: [UserModel]
    @Query private var configQuery: [ConfigModel]
    @Query private var messageQuery: [MessageModel]
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Possible values from config
    @State private var times: [Int] = []
    @State private var locations: [String] = []
    
    // User pick
    @State private var timePick: Int = 0
    @State private var locationPick: String = ""
    
    // View implementation
    var body: some View {
        VStack {
            VStack {
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        NavigationLink(destination: SavedView()) {
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
                    .onChange(of: timePick) { oldValue, newValue in
                        updateTime(newValue)
                    }
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
                        .onChange(of: locationPick) { oldValue, newValue in
                            updateLocation(newValue)
                        }
                    }
                    
                    HStack {
                        Text("Find me")
                        Image(systemName: "location.fill.viewfinder")
                    }
                    .foregroundStyle(Color.blue)
                    .onTapGesture {
                        let location = Locale.current.identifier
                        
                        if let match = locations.first(where: { $0.prefix(2) == location.suffix(2) }) {
                            locationPick = match
                        } else {
                            locationPick = locations.first!
                            alertMessage = "Your country is not supported please pick from available ones"
                            showAlert.toggle()
                        }
                    }
                })
                .padding(.vertical)
                
                Spacer()
                
                if messageQuery.count > 0 {
                    NavigationLink(destination: SupportMessageView(supportMessage: messageQuery[0])) {
                        Text("You have ^[\(messageQuery.count) message](inflect: true) from support!")
                            .font(.subheadline)
                    }
                    .padding(.vertical)
                }
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            times = configQuery.first!.times
            locations = Array((configQuery.first?.locations.keys)!)
            timePick = userQuery.first!.time
            locationPick = userQuery.first!.location
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Something went wrong"), message: Text(alertMessage), dismissButton: .default(Text("Continue")))
        }
    }
    
    private func updateTime(_ time: Int) {
        guard let user = userQuery.first else {
            return
        }
        
        do {
            user.time = time
            try modelContext.save()
        }
        catch {
            alertMessage = "Error happened during change please try again later"
            showAlert.toggle()
        }
    }
    
    private func updateLocation(_ location: String) {
        guard let user = userQuery.first else {
            return
        }
        
        var categories: [String: Int] = [:]
        for category in configQuery.first!.locations[location]! {
            categories[category] = user.categories[category] ?? 10
        }
        
        do {
            user.location = location
            user.categories = categories
            try modelContext.save()
        }
        catch {
            alertMessage = "Error happened during change please try again later"
            showAlert.toggle()
        }
    }
}
