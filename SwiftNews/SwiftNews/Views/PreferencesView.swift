//
//  PreferencesView.swift
//  SwiftNews
//

import Charts
import Foundation
import SwiftData
import SwiftUI

struct PreferencesView: View {
    // Database connection
    @Environment(\.modelContext) private var modelContext
    @Query private var userQuery: [UserModel]
    
    // All categories from query
    @State private var categories: [CategorySchema] = []
    
    // Category pick variables
    @State private var categoryPickInt: Int?
    @State private var categoryPick: CategorySchema? = nil
    
    // alert variables
    @State private var showAlert: Bool = false
    @State private var activeAlert: ActiveAlert = .error
    private enum ActiveAlert: String {
        case confirm, error, done
    }
    
    // View implementation
    var body: some View {
        VStack {
            VStack {
                Chart (categories) { category in
                    SectorMark(angle: .value("Points", category.value), innerRadius: .ratio(0.65), outerRadius: categoryPick?.id == category.id ? 175 : 150, angularInset: 1)
                        .cornerRadius(3)
                        .foregroundStyle(Color.foreground)
                        .opacity(categoryPick == nil ? 1.0 : (categoryPick?.id == category.id ? 1.0 : 0.5))
                }
                .frame(height: 300)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
                .chartLegend(.hidden)
                .chartAngleSelection(value: $categoryPickInt)
                .chartYAxis {
                    AxisMarks(stroke: StrokeStyle(lineWidth: 0))
                }
                .overlay(
                    VStack {
                        Text(categoryPick?.id ?? "Category")
                            .font(.title2)
                            .foregroundColor(Color.foreground)
                        Text(categoryPick?.value != nil ? String(categoryPick!.value - 10) : "likes")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                )
            }
            .onChange(of: categoryPickInt) { oldValue, newValue in
                if let newValue {
                    withAnimation {
                        getSelectedCategory(value: newValue)
                    }
                }
            }
            .overlay(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            categoryPick = nil
                        }
                    }
            )
            .onAppear {
                for (category, value) in userQuery.first!.categories {
                    categories.append(CategorySchema(
                        id: category,
                        value: value
                    ))
                }
            }
            
            Text("Click any chart segment to display category name and like number")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray)
                .font(.caption)
                .padding()
            
            Button(action: confirmAlert) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Reset preferences")
                }
                .padding()
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .background(Color.foreground)
                .foregroundStyle(Color.background)
                .cornerRadius(8)
            }
        }
        .padding(50)
        .navigationBarTitle("Your preferences", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            switch activeAlert {
            case .error:
                return Alert(title: Text("Error"), message: Text("Could not reset your preferences, try again later"), dismissButton: .default(Text("Continue")))
            case .confirm:
                return Alert(title: Text("Reset preferences"), message: Text("Would you like to reset your preferences? It can't be undone!"), primaryButton: .default(Text("Continue")) {
                    resetPreferences()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        activeAlert = .done
                        showAlert.toggle()
                    }
                }, secondaryButton: .cancel())
            case .done:
                return Alert(title: Text("Operation successful"), message: Text("Preferences are back to default"), dismissButton: .default(Text("Continue")))
            }
        }
    }
    
    private func confirmAlert() {
        activeAlert = .confirm
        showAlert.toggle()
    }
    
    private func getSelectedCategory(value: Int) {
        var total = 0
        _ = categories.first { category in
            total += category.value
            if value < total {
                categoryPick = category
                return true
            }
            return false
        }
    }
    
    private func resetPreferences() {
        var newCategories: [String: Int] = [:]
        for (category, _) in userQuery.first!.categories {
            newCategories[category] = 10
        }
        do {
            userQuery.first!.categories = newCategories
            try modelContext.save()
        }
        catch {
            activeAlert = .error
            showAlert = true
            return
        }
        
        categories = []
        for (category, value) in userQuery.first!.categories {
            categories.append(CategorySchema(
                id: category,
                value: value
            ))
        }
        
        categoryPick = nil
        categoryPickInt = nil
    }
}
