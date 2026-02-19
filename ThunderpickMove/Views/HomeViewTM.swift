import SwiftUI

struct HomeViewTM: View {
    @EnvironmentObject var viewModel: ViewModelTM
    @State private var animateScore = false
    @State private var showCheckIn = false
    
    var body: some View {
        ZStack {
            viewModel.currentTheme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    HStack {
                        Text("DASHBOARD")
                            .font(.custom("Rajdhani-Bold", size: 34))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Body Score
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 20)
                        
                        Circle()
                            .trim(from: 0, to: animateScore ? CGFloat(viewModel.userStats.bodyScore) / 100 : 0)
                            .stroke(viewModel.currentTheme.color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .glow(color: viewModel.currentTheme.color)
                        
                        VStack {
                            Text("\(viewModel.userStats.bodyScore)%")
                                .font(.custom("Rajdhani-Bold", size: 48))
                                .foregroundColor(.white)
                            Text("Body Score")
                                .font(.custom("Rajdhani-Medium", size: 16))
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 200, height: 200)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5)) {
                            animateScore = true
                        }
                    }
                    
                    // Status
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Current Status")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(viewModel.currentTheme.color)
                            Text(viewModel.userStats.currentStatus.rawValue)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .glass()
                    .padding(.horizontal)
                    
                    // Daily Power Move (Image + Action)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Daily Power Move")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                        }
                        
                        let move = viewModel.currentDailyMove
                        
                        VStack(alignment: .leading, spacing: 10) {
                            // Image Placeholder (In real app, assets would be loaded)
                            ZStack {
                                Rectangle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(height: 180)
                                    .cornerRadius(10)
                                
                                Image(systemName: "figure.walk") // Fallback/Placeholder
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                                    .foregroundColor(.gray)
                                
                                Text(move.imageName) // For missing assets debugging
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .offset(y: 60)
                            }
                            
                            Text(move.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(viewModel.currentTheme.color)
                            
                            Text(move.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                
                            if viewModel.isDailyMoveCompleted {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Completed")
                                }
                                .font(.headline)
                                .foregroundColor(viewModel.currentTheme.color)
                                .padding(.top, 5)
                            } else {
                                Button(action: {
                                    withAnimation {
                                        viewModel.completeDailyMove()
                                    }
                                }) {
                                    Text("Mark as Done")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(viewModel.currentTheme.color)
                                        .cornerRadius(12)
                                        .glow(color: viewModel.currentTheme.color)
                                }
                                .padding(.top, 5)
                            }
                        }
                    }
                    .padding()
                    .glass()
                    .padding(.horizontal)
                    
                    // Quick Check-in
                    Button(action: {
                        showCheckIn = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Quick Check-in: How are you?")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white) // Contrast for this secondary button
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showCheckIn) {
            CheckInSheet(isPresented: $showCheckIn)
        }
    }
}

struct CheckInSheet: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: ViewModelTM
    @State private var answer1 = 0.5
    @State private var answer2 = 0.5
    @State private var answer3 = 0.5
    
    var body: some View {
        ZStack {
            viewModel.currentTheme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("Quick Check-in")
                    .font(.custom("Rajdhani-Bold", size: 28))
                    .foregroundColor(viewModel.currentTheme.color)
                    .padding(.top, 20)
                
                VStack(alignment: .leading) {
                    Text("How open is your posture?")
                        .foregroundColor(.white)
                    Slider(value: $answer1)
                        .accentColor(viewModel.currentTheme.color)
                }
                
                VStack(alignment: .leading) {
                    Text("How relaxed is your face?")
                        .foregroundColor(.white)
                    Slider(value: $answer2)
                        .accentColor(viewModel.currentTheme.color)
                }
                
                VStack(alignment: .leading) {
                    Text("Energy level?")
                        .foregroundColor(.white)
                    Slider(value: $answer3)
                        .accentColor(viewModel.currentTheme.color)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.performCheckIn(posture: answer1, face: answer2, energy: answer3)
                    isPresented = false
                }) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.currentTheme.color)
                        .cornerRadius(12)
                        .glow(color: viewModel.currentTheme.color)
                }
            }
            .padding()
        }
    }
}
