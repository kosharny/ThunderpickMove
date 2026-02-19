import SwiftUI

// MARK: - Colors
extension Color {
    static let tmAccent = Color(hex: "D200FF") // Neon Purple
    static let tmBackground = Color(hex: "1a0b2e") // Deep Purple Background
    static let tmDarkBlue = Color(hex: "0a0f24")
}

// MARK: - Modifiers

struct GlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Material.ultraThinMaterial)
            .cornerRadius(15)
            .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 0)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
    }
}

struct GlowModifier: ViewModifier {
    var color: Color = .tmAccent
    var radius: CGFloat = 10
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
    }
}

extension View {
    func glass() -> some View {
        modifier(GlassModifier())
    }
    
    func glow(color: Color = .tmAccent, radius: CGFloat = 10) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }
}
