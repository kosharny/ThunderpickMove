import SwiftUI
import StoreKit

struct OnboardingViewTM: View {
    @EnvironmentObject var viewModel: ViewModelTM
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(image: "onb_master", title: "Master Your Presence", subtitle: "Improve your body language, movement, and facial expressions."),
        OnboardingPage(image: "onb_boost", title: "Boost Confidence", subtitle: "Influence others through conscious movements and awareness."),
        OnboardingPage(image: "onb_feedback", title: "Track Progress", subtitle: "Rate yourself and build new habits daily."),
        OnboardingPage(image: "onb_journey", title: "Start Your Journey", subtitle: "Move forward to daily practice and mastery.")
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Full screen TabView
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .ignoresSafeArea()
            
            // Bottom Button
            VStack {
                Spacer()
                
                Button(action: {
                    nextPage()
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.currentTheme.color) // Use current theme color
                        .cornerRadius(12)
                        .glow(color: viewModel.currentTheme.color) // Use current theme color
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 60)
            }
        }
        .onChange(of: currentPage) { newValue in
            if newValue == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    requestReview()
                }
            }
        }
    }
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func completeOnboarding() {
        viewModel.isOnboardingComplete = true
    }
}

struct OnboardingPage {
    let image: String
    let title: String
    let subtitle: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        ZStack {
            // Background Image
            Image(page.image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: -30) // Shift left to center the subject
                .ignoresSafeArea()
            
            // Gradient Overlay for text readability
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6), Color.black.opacity(0.9)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 20) {
                Spacer()
                
                Text(page.title)
                    .font(.custom("Rajdhani-Bold", size: 40))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Text(page.subtitle)
                    .font(.custom("Rajdhani-Medium", size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Extra space to push above the button and page indicators
                Spacer()
                    .frame(height: 160)
            }
            .frame(width: UIScreen.main.bounds.width)
        }
    }
}
