import SwiftUI

struct PrimaryButtonTM: View {
    @EnvironmentObject var viewModel: ViewModelTM
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Rajdhani-Bold", size: 18))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.currentTheme.color)
                .cornerRadius(12)
                .glow(color: viewModel.currentTheme.color, radius: 8)
        }
    }
}
