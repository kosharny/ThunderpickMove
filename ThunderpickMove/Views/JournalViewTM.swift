import SwiftUI
import PhotosUI
import AVFoundation

struct JournalViewTM: View {
    @EnvironmentObject var viewModel: ViewModelTM
    @State private var notes = ""
    @State private var selectedMood: MoodType = .confidence
    @State private var selectedTemplate: String?
    
    // Media State
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isRecording = false
    @State private var recordedAudioURL: URL?
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    
    let templates = [
        "Meeting/Negotiation": "Did I maintain eye contact? What was my posture?",
        "Date": "Did I mirror their gestures? Was I open?",
        "Public Speaking": "How was my voice projection? Did I pace?"
    ]
    
    var body: some View {
        ZStack {
            viewModel.currentTheme.backgroundColor.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Text("JOURNAL")
                        .font(.custom("Rajdhani-Bold", size: 34))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // List for content to enable Swipe-to-Delete
                List {
                    // Section 1: Input Controls (Wrapped in a single item to scroll together)
                    Group {
                        VStack(spacing: 20) {
                            // Mood
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(MoodType.allCases, id: \.self) { mood in
                                        Button(action: { selectedMood = mood }) {
                                            Text(mood.rawValue)
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(selectedMood == mood ? viewModel.currentTheme.color : Color.gray.opacity(0.3))
                                                .foregroundColor(selectedMood == mood ? .black : .white)
                                                .cornerRadius(20)
                                                .glow(color: selectedMood == mood ? viewModel.currentTheme.color : .clear)
                                        }
                                    }
                                }
                            }
                            
                            // Templates
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Situational Analysis")
                                    .font(.headline)
                                    .foregroundColor(viewModel.currentTheme.color)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(Array(templates.keys), id: \.self) { key in
                                            Button(action: {
                                                selectedTemplate = key
                                                if notes.isEmpty { notes = templates[key] ?? "" }
                                                else { notes += "\n\n" + (templates[key] ?? "") }
                                            }) {
                                                Text(key)
                                                    .font(.caption)
                                                    .padding(8)
                                                    .background(Color.white.opacity(0.1))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(8)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(selectedTemplate == key ? viewModel.currentTheme.color : Color.clear, lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Input Area
                            VStack(alignment: .leading) {
                                ZStack(alignment: .topLeading) {
                                    if notes.isEmpty {
                                        Text("Write your thoughts...")
                                            .foregroundColor(.gray)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 4)
                                    }
                                    TextEditor(text: $notes)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.clear)
                                        .foregroundColor(.white)
                                        .frame(minHeight: 120)
                                }
                                
                                // Media Previews
                                ScrollView(.horizontal) {
                                    HStack {
                                        if let image = selectedImage {
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 80, height: 80)
                                                    .cornerRadius(10)
                                                    .clipped()
                                                
                                                Button(action: { selectedImage = nil }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                        .background(Color.white.clipShape(Circle()))
                                                }
                                                .offset(x: 5, y: -5)
                                            }
                                        }
                                        
                                        if let _ = recordedAudioURL {
                                            HStack {
                                                Image(systemName: "mic.fill")
                                                    .foregroundColor(viewModel.currentTheme.color)
                                                Text("Audio Recorded")
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                                
                                                Button(action: { recordedAudioURL = nil }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                }
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            
                            // Actions Bar
                            HStack {
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    HStack {
                                        Image(systemName: "camera.fill")
                                        Text("Photo")
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(20)
                                }
                                .onChange(of: selectedItem) { newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                            selectedImage = uiImage
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    if isRecording { stopRecording() } else { startRecording() }
                                }) {
                                    HStack {
                                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill")
                                            .foregroundColor(isRecording ? .red : .white)
                                        Text(isRecording ? "Stop" : "Voice")
                                            .foregroundColor(isRecording ? .red : .white)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                    }
                                    .font(.subheadline)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(20)
                                }
                                
                                Spacer()
                                
                                Button(action: saveEntry) {
                                    Text("Save")
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(notes.isEmpty && selectedImage == nil && recordedAudioURL == nil ? Color.gray : viewModel.currentTheme.color)
                                        .foregroundColor(.black)
                                        .cornerRadius(20)
                                        .glow(color: notes.isEmpty && selectedImage == nil && recordedAudioURL == nil ? .clear : viewModel.currentTheme.color)
                                }
                                .disabled(notes.isEmpty && selectedImage == nil && recordedAudioURL == nil)
                            }
                        }
                        .padding()
                        .glass()
                        .padding(.horizontal)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .buttonStyle(.borderless) // Fix for buttons triggering simultaneously in List
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    
                    // Section 2: Timeline / History
                    Section(header: Text("HISTORY")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.leading)
                    ) {
                        ForEach(viewModel.journalEntries) { entry in
                            JournalEntryCard(entry: entry)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                        }
                        .onDelete(perform: viewModel.deleteJournalEntry)
                    }
                    
                    // Spacer for Custom Tab Bar
                    Section {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 80)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                // Removed padding from List frame to allow full screen scrolling.
                // Space for tabbar is handled by content inset or spacer inside list if needed.
            }
        }
        .onAppear {
            requestMicrophonePermission()
        }
    }
    
    // MARK: - Logic
    
    func saveEntry() {
        var photoPath: String?
        var audioPath: String?
        
        if let image = selectedImage {
            photoPath = viewModel.saveImage(image)
        }
        
        if let url = recordedAudioURL {
            audioPath = viewModel.saveAudio(from: url)
        }
        
        let entry = JournalEntry(
            date: Date(),
            mood: selectedMood,
            notes: notes,
            photoPath: photoPath,
            audioPath: audioPath
        )
        
        viewModel.addJournalEntry(entry)
        
        // Reset
        notes = ""
        selectedImage = nil
        selectedItem = nil
        recordedAudioURL = nil
        selectedTemplate = nil
    }
    
    // MARK: - Audio Recording
    
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            // Handle permission
        }
    }
    
    func startRecording() {
        let audioFilename = FileManager.default.temporaryDirectory.appendingPathComponent("temp_recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        recordedAudioURL = audioRecorder?.url
        isRecording = false
        audioRecorder = nil
    }
}

// MARK: - Journal Card Component

struct JournalEntryCard: View {
    let entry: JournalEntry
    @EnvironmentObject var viewModel: ViewModelTM
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: moodIcon(entry.mood))
                        .foregroundColor(.black)
                    Text(entry.mood.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(moodColor(entry.mood))
                .cornerRadius(12)
                
                Spacer()
                
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Notes
            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(4)
            }
            
            // Media
            if let photoPath = entry.photoPath,
               let uiImage = UIImage(contentsOfFile: viewModel.getDocumentsDirectory().appendingPathComponent(photoPath).path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .cornerRadius(12)
                    .clipped()
            }
            
            if let audioPath = entry.audioPath {
                Button(action: {
                    playAudio(path: audioPath)
                }) {
                    HStack {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .foregroundColor(.black)
                        Text(isPlaying ? "Stop Voice Note" : "Play Voice Note")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "waveform")
                            .foregroundColor(.black.opacity(0.5))
                    }
                    .padding()
                    .background(viewModel.currentTheme.color)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    func playAudio(path: String) {
        if isPlaying {
            audioPlayer?.stop()
            isPlaying = false
            return
        }
        
        let url = viewModel.getDocumentsDirectory().appendingPathComponent(path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            isPlaying = true
            
            // Simple timer to reset state (in real app, use delegate)
            DispatchQueue.main.asyncAfter(deadline: .now() + (audioPlayer?.duration ?? 0)) {
                self.isPlaying = false
            }
        } catch {
            print("Could not play audio: \(error)")
        }
    }
    
    func moodColor(_ mood: MoodType) -> Color {
        switch mood {
        case .confidence: return viewModel.currentTheme.color
        case .stress: return .red
        case .dominance: return .purple
        }
    }
    
    func moodIcon(_ mood: MoodType) -> String {
        switch mood {
        case .confidence: return "star.fill"
        case .stress: return "exclamationmark.triangle.fill"
        case .dominance: return "crown.fill"
        }
    }
}
