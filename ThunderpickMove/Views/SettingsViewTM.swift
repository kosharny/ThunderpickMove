import SwiftUI
import WebKit

struct SettingsViewTM: View {
    @EnvironmentObject var viewModel: ViewModelTM
    @StateObject private var store = StoreManagerTM.shared
    
    @State private var selectedThemeForPaywall: ThemeType?
    @State private var showMasterclass = false
    @State private var showAbout = false
    @State private var showRestoreSuccess = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                viewModel.currentTheme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    HStack {
                        Text("SETTINGS")
                            .font(.custom("Rajdhani-Bold", size: 34))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Theme Selector
                    VStack(alignment: .leading, spacing: 15) {
                        Text("THEMES")
                            .font(.headline)
                            .foregroundColor(viewModel.currentTheme.color)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                            ThemeCard(theme: .standard, price: "Free", isPurchased: true, isSelected: viewModel.currentTheme == .standard) {
                                viewModel.setTheme(.standard)
                            }
                            
                            ThemeCard(theme: .neonCyber, price: "$1.99", isPurchased: store.hasAccess(to: .neonCyber), isSelected: viewModel.currentTheme == .neonCyber) {
                                if store.hasAccess(to: .neonCyber) {
                                    viewModel.setTheme(.neonCyber)
                                } else {
                                    selectedThemeForPaywall = .neonCyber
                                }
                            }
                            
                            ThemeCard(theme: .stealthOps, price: "$1.99", isPurchased: store.hasAccess(to: .stealthOps), isSelected: viewModel.currentTheme == .stealthOps) {
                                if store.hasAccess(to: .stealthOps) {
                                    viewModel.setTheme(.stealthOps)
                                } else {
                                    selectedThemeForPaywall = .stealthOps
                                }
                            }
                        }
                    }
                    .padding()
                    .glass()
                    .padding(.horizontal)
                    
                    // Restore Purchases
                    Button(action: {
                        Task {
                            await store.restorePurchases()
                            await MainActor.run {
                                showRestoreSuccess = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.gray)
                            Text("Restore Purchases")
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Masterclass
                    Button(action: {
                        showMasterclass = true
                    }) {
                        HStack {
                            Image(systemName: "play.rectangle.fill")
                                .foregroundColor(.red)
                            Text("Open Masterclass")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .glass()
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        showAbout = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("About Thunderpick Move")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .glass()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                    .navigationDestination(isPresented: $showAbout) {
                        AboutViewTM()
                    }
                }
            }
        }
        .sheet(item: $selectedThemeForPaywall) { theme in
            PaywallViewTM(theme: theme)
        }
        .sheet(isPresented: $showMasterclass) {
            WebView(url: URL(string: "https://www.youtube.com/watch?time_continue=2&v=Ks-_Mh1QhMc&embeds_referring_euri=https%3A%2F%2Fchatgpt.com%2F&source_ve_path=Mjg2NjY")!)
                .ignoresSafeArea()
        }
        .alert("Purchases Restored", isPresented: $showRestoreSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your previous purchases have been restored successfully.")
        }
    }
    }
}

struct ThemeCard: View {
    let theme: ThemeType
    let price: String
    let isPurchased: Bool
    let isSelected: Bool
    let action: () -> Void
    
    var textColor: Color {
        return theme == .neonCyber ? .black : .white
    }
    
    var body: some View {
        Button(action: action) {
            VStack {
                // Icon Area
                VStack {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(textColor)
                    } else if !isPurchased {
                        Image(systemName: "lock.fill")
                            .font(.title)
                            .foregroundColor(textColor.opacity(0.7))
                    } else {
                        Image(systemName: "paintpalette.fill")
                            .font(.title)
                            .foregroundColor(textColor.opacity(0.5))
                    }
                }
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                
                // Text Area
                VStack(spacing: 4) {
                    Text(theme.rawValue.capitalized)
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    Text(isPurchased ? "Owned" : price)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(textColor.opacity(0.8))
                }
                .padding(.bottom, 12)
            }
            .background(theme.color)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
            )
            .shadow(color: theme.color.opacity(0.5), radius: 8, x: 0, y: 4)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(), value: isSelected)
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
