import SwiftUI
import StoreKit

struct PaywallViewTM: View {
    let theme: ThemeType
    
    @StateObject private var store = StoreManagerTM.shared
    @Environment(\.dismiss) var dismiss
    
    // Alert State
    @State private var showConfirmAlert = false
    @State private var showResultAlert = false
    @State private var resultTitle = ""
    @State private var resultMessage = ""
    @State private var isSuccess = false
    @State private var selectedProduct: Product?
    
    var body: some View {
        ZStack {
            // Background
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Close Button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header / Icon
                        ZStack {
                            Circle()
                                .fill(theme.color.opacity(0.2))
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .stroke(theme.color, lineWidth: 2)
                                .frame(width: 120, height: 120)
                                .shadow(color: theme.color, radius: 10)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 50))
                                .foregroundColor(theme.color)
                        }
                        .padding(.top, 20)
                        
                        // Title
                        VStack(spacing: 10) {
                            Text("UNLOCK \(theme.rawValue.uppercased())")
                                .font(.custom("Rajdhani-Bold", size: 32))
                                .foregroundColor(.white)
                            
                            Text("Premium Theme Experience")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        
                        // Features
                        VStack(alignment: .leading, spacing: 20) {
                            FeatureRow(icon: "paintpalette.fill", title: "Exclusive Colors", description: "Apply the \(theme.rawValue) color scheme.")
                            FeatureRow(icon: "star.fill", title: "Support Development", description: "Help us build more features.")
                            FeatureRow(icon: "lock.open.fill", title: "Lifetime Access", description: "One-time purchase, yours forever.")
                        }
                        .padding()
                        .glass() // Assuming glass modifier exists
                        
                        Spacer(minLength: 20)
                        
                        // Purchase Button
                        if let product = store.products.first(where: { $0.id == theme.productID }) {
                            Button(action: {
                                selectedProduct = product
                                showConfirmAlert = true
                            }) {
                                HStack {
                                    Text("Unlock for \(product.displayPrice)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(theme.color)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .glow(color: theme.color) // Assuming glow modifier exists
                            }
                            
                            // Restore
                            Button(action: {
                                Task {
                                    await store.restorePurchases()
                                    checkPurchaseStatus()
                                }
                            }) {
                                Text("Restore Purchases")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.top, 8)
                            }
                        } else {
                            if store.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Product not found")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                Button("Retry Loading") {
                                    Task { await store.fetchProducts() }
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .customAlert(isPresented: $showConfirmAlert, alert: confirmAlert, themeColor: theme.color)
        .customAlert(isPresented: $showResultAlert, alert: resultAlert, themeColor: theme.color)
        .task {
            if store.products.isEmpty {
                await store.fetchProducts()
            }
        }
    }
    
    // MARK: - Alerts
    
    var confirmAlert: CustomAlertTM {
        CustomAlertTM(
            title: "Confirm Purchase",
            message: "Unlock \(theme.rawValue.capitalized) theme for \(selectedProduct?.displayPrice ?? "price")?",
            primaryButton: .init(title: "Purchase", isPrimary: true, action: {
                showConfirmAlert = false
                Task { await performPurchase() }
            }),
            secondaryButton: .init(title: "Cancel", action: {
                showConfirmAlert = false
            })
        )
    }
    
    var resultAlert: CustomAlertTM {
        CustomAlertTM(
            title: resultTitle,
            message: resultMessage,
            primaryButton: .init(title: "OK", isPrimary: true, action: {
                showResultAlert = false
                if isSuccess { dismiss() }
            })
        )
    }
    
    // MARK: - Actions
    
    func performPurchase() async {
        guard let product = selectedProduct else { return }
        let status = await store.purchase(product)
        
        switch status {
        case .success:
            resultTitle = "Success!"
            resultMessage = "Theme unlocked successfully."
            isSuccess = true
        case .pending:
            resultTitle = "Pending"
            resultMessage = "Transaction is pending approval."
            isSuccess = false
        case .cancelled:
            return // No alert needed
        case .failed:
            resultTitle = "Failed"
            resultMessage = "Purchase could not be completed."
            isSuccess = false
        }
        
        if status != .cancelled {
            showResultAlert = true
        }
    }
    
    func checkPurchaseStatus() {
        if store.hasAccess(to: theme) {
            resultTitle = "Restored"
            resultMessage = "Purchases restored successfully."
            isSuccess = true
            showResultAlert = true
        } else {
             // Optional: Show "No purchases found" but might be annoying if automatic
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}
