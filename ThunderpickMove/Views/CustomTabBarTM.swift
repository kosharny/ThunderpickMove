import SwiftUI

struct CustomTabBarTM: View {
    @Binding var selectedTab: Int
    var themeColor: Color // New property
    
    let tabs = [
        ("house.fill", "Home"),
        ("book.fill", "Journal"),
        ("figure.run", "Activity"),
        ("chart.bar.fill", "Stats"),
        ("gearshape.fill", "Settings")
    ]
    
    var body: some View {
        HStack {
            ForEach(0..<tabs.count, id: \.self) { index in
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].0)
                            .font(.system(size: 24))
                            .scaleEffect(selectedTab == index ? 1.2 : 1.0)
                        
                        // Indicator dot
                        if selectedTab == index {
                            Circle()
                                .fill(themeColor)
                                .frame(width: 5, height: 5)
                                .glow(color: themeColor, radius: 5)
                        }
                    }
                    .foregroundColor(selectedTab == index ? themeColor : .gray)
                }
                Spacer()
            }
        }
        .padding(.vertical, 15)
        .background(Color.black.opacity(0.8))
        .background(Material.ultraThinMaterial)
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(LinearGradient(colors: [.white.opacity(0.1), .clear], startPoint: .top, endPoint: .bottom), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
