import SwiftUI

struct AboutViewTM: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.tmBackground.ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("ABOUT")
                        .font(.custom("Rajdhani-Bold", size: 24))
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding()
                
                Spacer()
                
                Image("mainLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                
                Text("Version 1.0")
                    .font(.body)
                    .foregroundColor(.gray)
                
                Text("Master your presence. Dominate your space.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                Text("Created by Thunderpick Team")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
}
