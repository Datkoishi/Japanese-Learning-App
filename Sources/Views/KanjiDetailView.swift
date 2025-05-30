import SwiftUI
import PencilKit

public struct KanjiDetailView: View {
    let kanji: Kanji
    @StateObject private var kanjiDataManager = KanjiDataManager()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var progressManager = UserProgressManager()
    
    @State private var canvasView = PKCanvasView()
    @State private var showingStrokeOrder = false
    @State private var currentStrokeIndex = 0
    @State private var showingWritingPractice = false
    @State private var savedDrawings: [PKDrawing] = []
    
    public init(kanji: Kanji) {
        self.kanji = kanji
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with kanji character
                kanjiHeaderView
                
                // Information card
                kanjiInfoCard
                
                // Example section
                exampleSection
                
                // Action buttons
                actionButtonsSection
                
                // Stroke order section
                if showingStrokeOrder {
                    strokeOrderSection
                }
                
                // Writing practice section
                if showingWritingPractice {
                    writingPracticeSection
                }
                
                // Progress section
                progressSection
            }
            .padding()
        }
        .navigationTitle("Chi tiết Kanji")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    kanjiDataManager.toggleBookmark(for: kanji.id)
                }) {
                    Image(systemName: kanji.isBookmarked ? "heart.fill" : "heart")
                        .foregroundColor(kanji.isBookmarked ? .red : .gray)
                }
            }
        }
        .onAppear {
            kanjiDataManager.updateKanjiProgress(for: kanji.id)
            progressManager.updateStudyTime(5) // 5 minutes for viewing
        }
    }
    
    private var kanjiHeaderView: some View {
        VStack(spacing: 16) {
            Text(kanji.character)
                .font(.system(size: 120, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                Text(kanji.meaning)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                
                HStack(spacing: 16) {
                    VStack {
                        Text("Kana")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(kanji.kana)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    
                    VStack {
                        Text("Romaji")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(kanji.romaji)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    
                    VStack {
                        Text("Số nét")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(kanji.strokeCount)")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var kanjiInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Thông tin")
                .font(.headline)
            
            VStack(spacing: 8) {
                InfoRow(label: "Nghĩa", value: kanji.meaning)
                InfoRow(label: "Cách đọc", value: "\(kanji.kana) (\(kanji.romaji))")
                InfoRow(label: "Số nét viết", value: "\(kanji.strokeCount)")
                
                if kanji.practiced > 0 {
                    InfoRow(label: "Đã luyện tập", value: "\(kanji.practiced) lần")
                }
                
                if let lastPracticed = kanji.lastPracticed {
                    InfoRow(label: "Lần cuối luyện", value: formatDate(lastPracticed))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4)
    }
    
    private var exampleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ví dụ từ ghép")
                .font(.headline)
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(kanji.example)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("\(kanji.exampleKana) (\(kanji.exampleRomaji))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(kanji.exampleMeaning)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        audioManager.playAudio(for: kanji.example)
                    }) {
                        Image(systemName: audioManager.isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                    .disabled(audioManager.isPlaying)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                KanjiActionButton(
                    title: "Thứ tự nét",
                    icon: "pencil.and.outline",
                    color: .blue,
                    isActive: showingStrokeOrder
                ) {
                    withAnimation {
                        showingStrokeOrder.toggle()
                        if showingStrokeOrder {
                            currentStrokeIndex = 0
                        }
                    }
                }
                
                KanjiActionButton(
                    title: "Luyện viết",
                    icon: "pencil.tip",
                    color: .green,
                    isActive: showingWritingPractice
                ) {
                    withAnimation {
                        showingWritingPractice.toggle()
                    }
                }
            }
            
            HStack(spacing: 12) {
                KanjiActionButton(
                    title: "Phát âm",
                    icon: "speaker.wave.2",
                    color: .orange,
                    isActive: audioManager.isPlaying
                ) {
                    audioManager.playAudio(for: kanji.kana)
                }
                
                KanjiActionButton(
                    title: kanji.isBookmarked ? "Đã lưu" : "Lưu",
                    icon: kanji.isBookmarked ? "heart.fill" : "heart",
                    color: .red,
                    isActive: kanji.isBookmarked
                ) {
                    kanjiDataManager.toggleBookmark(for: kanji.id)
                }
            }
        }
    }
    
    private var strokeOrderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Thứ tự nét viết")
                .font(.headline)
            
            if !kanji.strokeOrder.isEmpty {
                VStack(spacing: 16) {
                    // Stroke visualization area
                    ZStack {
                        // Grid background
                        StrokeOrderGrid()
                        
                        // Strokes
                        ForEach(0...currentStrokeIndex, id: \.self) { index in
                            if index < kanji.strokeOrder.count {
                                StrokeView(path: kanji.strokeOrder[index])
                                    .stroke(Color.accentColor, lineWidth: 3)
                            }
                        }
                    }
                    .frame(width: 200, height: 200)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Controls
                    HStack {
                        Button(action: {
                            if currentStrokeIndex > 0 {
                                currentStrokeIndex -= 1
                            }
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.title2)
                                .foregroundColor(currentStrokeIndex > 0 ? .accentColor : .gray)
                        }
                        .disabled(currentStrokeIndex == 0)
                        
                        Spacer()
                        
                        Text("Nét \(currentStrokeIndex + 1)/\(kanji.strokeOrder.count)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Button(action: {
                            if currentStrokeIndex < kanji.strokeOrder.count - 1 {
                                currentStrokeIndex += 1
                            }
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                                .foregroundColor(currentStrokeIndex < kanji.strokeOrder.count - 1 ? .accentColor : .gray)
                        }
                        .disabled(currentStrokeIndex >= kanji.strokeOrder.count - 1)
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("Thứ tự nét viết chưa có sẵn")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4)
    }
    
    private var writingPracticeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Luyện viết tay")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Canvas area
                KanjiCanvasView(canvasView: $canvasView, kanji: kanji)
                    .frame(height: 250)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 4)
                
                // Canvas controls
                HStack(spacing: 12) {
                    Button(action: {
                        canvasView.drawing = PKDrawing()
                    }) {
                        Label("Xóa", systemImage: "trash")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        savedDrawings.append(canvasView.drawing)
                        kanjiDataManager.updateKanjiProgress(for: kanji.id, masteryChange: 1)
                        progressManager.updateKanjiProgress()
                    }) {
                        Label("Lưu", systemImage: "checkmark")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Text("Đã lưu: \(savedDrawings.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4)
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tiến độ học tập")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Mastery level
                HStack {
                    Text("Mức độ thành thạo")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < kanji.masteryLevel ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.system(size: 16))
                        }
                    }
                }
                
                // Practice count
                HStack {
                    Text("Số lần luyện tập")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(kanji.practiced) lần")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                // Last practiced
                if let lastPracticed = kanji.lastPracticed {
                    HStack {
                        Text("Lần cuối luyện")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text(formatDate(lastPracticed))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Helper Views
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct KanjiActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isActive ? color.opacity(0.2) : Color(.systemGray6))
            .foregroundColor(isActive ? color : .primary)
            .cornerRadius(12)
        }
    }
}

struct StrokeOrderGrid: View {
    var body: some View {
        ZStack {
            // Outer border
            Rectangle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
            
            // Center lines
            Path { path in
                path.move(to: CGPoint(x: 100, y: 0))
                path.addLine(to: CGPoint(x: 100, y: 200))
                path.move(to: CGPoint(x: 0, y: 100))
                path.addLine(to: CGPoint(x: 200, y: 100))
            }
            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            
            // Diagonal lines
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 200, y: 200))
                path.move(to: CGPoint(x: 200, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 200))
            }
            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        }
    }
}

struct StrokeView: Shape {
    let path: String
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let commands = self.path.components(separatedBy: " ")
        var index = 0
        
        while index < commands.count {
            let command = commands[index]
            
            if command == "M" && index + 2 < commands.count {
                let x = Double(commands[index + 1].replacingOccurrences(of: ",", with: "")) ?? 0
                let y = Double(commands[index + 2]) ?? 0
                path.move(to: CGPoint(x: x, y: y))
                index += 3
            } else if command == "L" && index + 2 < commands.count {
                let x = Double(commands[index + 1].replacingOccurrences(of: ",", with: "")) ?? 0
                let y = Double(commands[index + 2]) ?? 0
                path.addLine(to: CGPoint(x: x, y: y))
                index += 3
            } else {
                index += 1
            }
        }
        
        return path
    }
}

struct KanjiCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let kanji: Kanji
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 4)
        canvasView.backgroundColor = .white
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        
        // Add guide character
        addGuideCharacter()
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Updates when binding changes
    }
    
    private func addGuideCharacter() {
        // Add a light gray guide character in the background
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        let image = renderer.image { context in
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 120, weight: .bold),
                .foregroundColor: UIColor.lightGray.withAlphaComponent(0.3)
            ]
            
            let text = kanji.character
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(
                x: (200 - size.width) / 2,
                y: (200 - size.height) / 2,
                width: size.width,
                height: size.height
            )
            
            text.draw(in: rect, withAttributes: attributes)
        }
        
        // Convert to PKDrawing and set as background
        // This is a simplified approach - in a real app you'd want to handle this more elegantly
    }
}
