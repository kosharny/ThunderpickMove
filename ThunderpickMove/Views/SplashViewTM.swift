import SwiftUI
import AppTrackingTransparency
import Combine

struct SplashViewTM: View {
    @State private var isActive = false
    @State private var opacity = 0.5
    @State private var size = 0.8
    @State private var progress: CGFloat = 0.0
    @State private var percentage: Int = 0
    let timer = Timer.publish(every: 0.015, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if isActive {
            MainViewTM()
        } else {
            ZStack {
                Color.tmBackground.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Image("mainLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .scaleEffect(size)
                        .opacity(opacity)
                    
                    VStack(spacing: 10) {
                        // Progress Bar Container
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 12)
                            
                            Capsule()
                                .fill(Color.tmAccent)
                                .frame(width: max(0, UIScreen.main.bounds.width * 0.7 * progress), height: 12)
                                .glow(color: Color.tmAccent, radius: 5)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.7)
                        
                        // Percentage Text
                        Text("\(percentage)%")
                            .font(.custom("Rajdhani-Bold", size: 24))
                            .foregroundColor(.white)
                    }
                    .opacity(opacity)
                }
                .onAppear {
                    withAnimation(.easeIn(duration: 0.8)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                }
                .onReceive(timer) { _ in
                    if progress < 1.0 {
                        progress += 0.01
                        percentage = min(100, Int(progress * 100))
                    } else {
                        timer.upstream.connect().cancel()
                        finishLoading()
                    }
                }
            }
        }
    }
    
    private func finishLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
