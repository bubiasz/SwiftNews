//
//  SwiftNews
//

import Charts
import SwiftData
import SwiftUI


struct PreferencesView: View {
    @State private var selectedCategory: Int?
    @State private var selectedCategoryName: CategoryModel?
    @State var innerText: String = "Your Content Here"
    
    @Query var categories: [CategoryModel]
    
//    let categoryList: [CategorySchema] = [
//        CategorySchema(name: "Country", value: 10),
//        CategorySchema(name: "World", value: 20),
//        CategorySchema(name: "Local", value: 5),
//        CategorySchema(name: "Business", value: 40),
//        CategorySchema(name: "Technology", value: 50),
//        CategorySchema(name: "Entertainment", value: 70),
//        CategorySchema(name: "Sports", value: 30),
//        CategorySchema(name: "Science", value: 30),
//        CategorySchema(name: "Health", value: 20),
//    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                VStack {
                    VStack {
                        Chart (categories) { category in
                            SectorMark(
                                angle: .value("Points", category.value),
                                innerRadius: .ratio(0.65),
                                outerRadius: selectedCategoryName?.name == category.name ? 175 : 150,
                                angularInset: 1)
                            .foregroundStyle(Color.foreground)
                            .cornerRadius(3)
                            .opacity(selectedCategoryName == nil ? 1.0 : (selectedCategoryName?.name == category.name ? 1.0 : 0.5))
                        }
                        .chartLegend(.hidden)
                        .chartAngleSelection(value: $selectedCategory)
                        .padding()
                        .chartYAxis {
                            AxisMarks(stroke: StrokeStyle(lineWidth: 0))
                        }
                        .frame(height: 300)
                    }
                    .overlay(
                        VStack {
                            Text(selectedCategoryName?.name ?? "Category")
                                .font(.title2)
                                .foregroundColor(Color.foreground)
                            Text(selectedCategoryName?.value != nil ? String(selectedCategoryName!.value) : "likes")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    )
                    .onChange(of: selectedCategory, { oldValue, newValue in
                        if let newValue {
                            withAnimation {
                                getSelectedCategory(value: newValue)
                            }
                        }
                    })
                    .padding()
                }
                Text("Click any chart segment to display category name and like number")
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
                Spacer()
                VStack {
                    Button(action: {
                        // Action
                    }) {
                        Text("Reset preferences")
                            .foregroundColor(Color.background)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.foreground)
                            .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .padding()
            .navigationTitle("Your preferences")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            selectedCategoryName = nil
                        }
                    }
            )
            .padding()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func getSelectedCategory(value: Int) {
        var total = 0
        _ = categories.first { category in
            total += category.value
            if value <= total {
                selectedCategoryName = category
                return true
            }
            return false
        }
    }
}

//#Preview {
//    PreferencesView()
//}
