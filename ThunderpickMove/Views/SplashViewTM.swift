import SwiftUI
import AppTrackingTransparency

struct SplashViewTM: View {
    @State private var isActive = false
    @State private var opacity = 0.5
    @State private var size = 0.8
    
    var body: some View {
        if isActive {
            MainViewTM()
        } else {
            ZStack {
                Color.tmBackground.ignoresSafeArea()
                
                VStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.tmAccent)
                        .glow()
                    
                    Text("THUNDERPICK\nMOVE")
                        .font(.custom("Rajdhani-Bold", size: 40))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    ATTrackingManager.requestTrackingAuthorization { status in
                        DispatchQueue.main.async {
                            withAnimation {
                                self.isActive = true
                            }
                        }
                    }
                }
            }
        }
    }
}
