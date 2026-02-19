import SwiftUI
import StoreKit

struct OnboardingViewTM: View {
    @EnvironmentObject var viewModel: ViewModelTM
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(image: "power_pose", title: "Master Your Presence", subtitle: "Improve your body language, movement, and facial expressions."),
        OnboardingPage(image: "morning_sunny_clouds", title: "Boost Confidence", subtitle: "Influence others through conscious movements and awareness."),
        OnboardingPage(image: "coffee_cup", title: "Give Feedback", subtitle: "Rate yourself and track your progress daily."),
        OnboardingPage(image: "magnetic_walk", title: "Start Your Journey", subtitle: "Move forward to daily practice and mastery.")
    ]
    
    var body: some View {
            ZStack {
                Color.tmBackground.ignoresSafeArea()
                
                VStack {
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingPageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    
                    Button(action: {
                        nextPage()
                    }) {
                        Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.tmAccent)
                            .cornerRadius(12)
                            .glow()
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
                .onChange(of: currentPage) { newValue in
                    if newValue == 2 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            requestReview()
                        }
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
        VStack(spacing: 20) {
            Image(page.image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 400)
                .cornerRadius(20)
                .padding()
            
            Text(page.title)
                .font(.custom("Rajdhani-Bold", size: 32))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(page.subtitle)
                .font(.custom("Rajdhani-Regular", size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 50)
    }
}
