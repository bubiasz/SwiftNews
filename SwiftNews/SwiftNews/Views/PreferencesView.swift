//
//  SwiftNews
//

import Charts
import SwiftData
import SwiftUI


struct PreferencesView: View {
    @State private var selectedCategory: Int?
//    @State private var selectedCategoryName: CategoryModel?
    @State private var innerText: String = "Your Content Here"
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var userQuery: [UserModel]
    
    @State private var categories: [CategorySchema]?
    @State private var categoryPick: CategorySchema? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                VStack {
//                    VStack {
//                        Chart (categories) { category in
//                            SectorMark(
//                                angle: .value("Points", category.value),
//                                innerRadius: .ratio(0.65),
//                                outerRadius: categoryPick?.name == category.name ? 175 : 150,
//                                angularInset: 1)
//                            .foregroundStyle(Color.foreground)
//                            .cornerRadius(3)
//                            .opacity(categoryPick == nil ? 1.0 : (categoryPick?.name == category.name ? 1.0 : 0.5))
//                        }
//                        .chartLegend(.hidden)
//                        .chartAngleSelection(value: $selectedCategory)
//                        .padding()
//                        .chartYAxis {
//                            AxisMarks(stroke: StrokeStyle(lineWidth: 0))
//                        }
//                        .frame(height: 300)
//                    }
//                    .overlay(
//                        VStack {
//                            Text(categoryPick?.name ?? "Category")
//                                .font(.title2)
//                                .foregroundColor(Color.foreground)
//                            Text(categoryPick?.value != nil ? String(categoryPick!.value) : "likes")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//                    )
//                    .onChange(of: selectedCategory, { oldValue, newValue in
//                        if let newValue {
//                            withAnimation {
//                                getSelectedCategory(value: newValue)
//                            }
//                        }
//                    })
//                    .padding()
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
//            .overlay(
////                Color.clear
////                    .contentShape(Rectangle())
////                    .onTapGesture {
////                        withAnimation {
////                            categoryPick = nil
////                        }
////                    }
//            )
            .padding()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear() {
//                categories = Array()
//                for (category, value) in userQuery.first!.categories! {
//                    categories.append(CategorySchema(
//                        name: category,
//                        value: value
//                    ))
//                }
//                print(categories!)
            }
        }
    }
    
    private func getSelectedCategory(value: Int) {
//        var total = 0
//        _ = categories!.first { category in
//            total += category.value
//            if value <= total {
//                categoryPick = category
//                return true
//            }
//            return false
//        }
    }
}

//#Preview {
//    PreferencesView()
//}
