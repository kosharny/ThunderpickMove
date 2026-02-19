import SwiftUI

struct CustomAlertTM {
    var title: String
    var message: String
    var primaryButton: AlertButton
    var secondaryButton: AlertButton?
    
    struct AlertButton {
        var title: String
        var isPrimary: Bool = false
        var action: (() -> Void)?
    }
}

struct CustomAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let alert: CustomAlertTM
    var themeColor: Color = .tmAccent // Default to static, but overridable
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isPresented)
                .blur(radius: isPresented ? 3 : 0)
            
            if isPresented {
                // Background removed as per user request
                
                VStack(spacing: 20) {
                    Text(alert.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(alert.message)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 16) {
                        if let secondary = alert.secondaryButton {
                            Button(action: {
                                secondary.action?()
                            }) {
                                Text(secondary.title)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        
                        Button(action: {
                            alert.primaryButton.action?()
                        }) {
                            Text(alert.primaryButton.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(themeColor) // Dynamic theme color
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(24)
                .background(Color.tmBackground)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10) // Drop shadow instead of glass
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(32)
            }
        }
        .animation(.spring(), value: isPresented)
    }
}

extension View {
    func customAlert(isPresented: Binding<Bool>, alert: CustomAlertTM, themeColor: Color = .tmAccent) -> some View {
        self.modifier(CustomAlertModifier(isPresented: isPresented, alert: alert, themeColor: themeColor))
    }
}
