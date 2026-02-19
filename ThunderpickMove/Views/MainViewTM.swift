import SwiftUI

struct MainViewTM: View {
    @EnvironmentObject var viewModel: ViewModelTM
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if !viewModel.isOnboardingComplete {
                OnboardingViewTM()
            } else {
                ZStack(alignment: .bottom) {
                    TabView(selection: $selectedTab) {
                        HomeViewTM()
                            .tag(0)
                        
                        JournalViewTM()
                            .tag(1)
                        
                        ActivityViewTM()
                            .tag(2)
                        
                        StatsViewTM()
                            .tag(3)
                        
                        SettingsViewTM()
                            .tag(4)
                    }
                    .id(viewModel.currentTheme.id) // Force recreation on theme change
                    // Removed .tabViewStyle(.page) to fix conflict with List swipe-to-delete
                    // Tabs will now be switched only via CustomTabBarTM
                    // Note: If we use PageTabViewStyle, swipe works but we need to sync binding. 
                    // Let's stick to 'ZStack' switching or TabView without swipe if we want strict control. 
                    // But TabView is good for maintaining state.
                    
                    CustomTabBarTM(selectedTab: $selectedTab, themeColor: viewModel.currentTheme.color)
                        .padding(.bottom, 20) // Adjust for safe area
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .accentColor(viewModel.currentTheme.color) // Apply theme globally to standard controls
            }
        }
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithTransparentBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().isHidden = true
        }
    }
}
