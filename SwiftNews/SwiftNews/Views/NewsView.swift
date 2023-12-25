//
//  SwiftNews
//

import SwiftUI


struct NewsView: View {
    
    @State var isTitleExpanded: Bool = false
    @State var isContentExpanded: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(Color("foreground"))
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
                }
                
                Spacer()
                
                ScrollView {
                    Text("Lorem ipsum dolor sit amet, consectetur")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        .lineLimit(isTitleExpanded ? nil : 1)
                        .onTapGesture {
                            withAnimation {
                                isTitleExpanded.toggle()
                            }
                        }
                    
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin neque felis, pellentesque a ipsum at, tincidunt tincidunt eros. Phasellus commodo ligula lobortis, consectetur ipsum id, dignissim justo. Integer sollicitudin aliquet lacinia. Fusce tortor felis, sagittis in tellus id, euismod auctor mauris. Nullam convallis libero id orci sagittis vehicula. Integer eu ante non enim aliquam euismod. Nulla at pellentesque lectus. Suspendisse sit amet purus et ipsum bibendum bibendum ut vitae nisi. Aenean eros nunc, dignissim ut justo non, cursus sodales arcu. Donec condimentum euismod eros a rutrum. Vestibulum eget quam ut nisi luctus tristique. Vivamus lobortis est vitae vulputate mollis. Vivamus turpis libero, accumsan ut dolor nec, finibus ultrices orci. Aliquam porttitor enim in lorem semper, non gravida est rhoncus. Donec quis tellus id ante hendrerit cursus. Nunc elementum quam eget eros tincidunt efficitur. Donec velit sem, dictum ac felis eu, commodo sollicitudin nulla. Curabitur justo justo, elementum in rhoncus vel, posuere sed lectus. Etiam et vestibulum est, ullamcorper ornare metus. Etiam in arcu vitae leo luctus tincidunt ac eu velit. Vivamus a efficitur nisi, luctus egestas mauris. Donec in sodales nulla. Sed in sem viverra, hendrerit nulla in, placerat ex. Donec sed risus fermentum, cursus ipsum vel, luctus risus. Duis vulputate pulvinar ligula, mattis rhoncus tellus aliquam non.")
                        .padding(.bottom)
                        .lineLimit(isContentExpanded ? nil : 20)
                        .onTapGesture {
                            withAnimation {
                                isContentExpanded.toggle()
                            }
                        }
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "hand.thumbsup.fill")
                        
                        Spacer()
                        
                        Image(systemName: "hand.thumbsdown.fill")
                        
                        Spacer()
                        
                        Image(systemName: "heart.fill")
                        
                        Spacer()
                        
                        Image(systemName: "globe")
                        
                        Spacer()
                        
                        Image(systemName: "square.and.arrow.up.fill")
                        
                        Spacer()
                    }
                    .padding()
                }
                .padding(.vertical)
                .frame(maxHeight: 595)
            }
            .padding()
        }
    }
    
}

//#Preview {
//    NewsView()
//}
