import SwiftUI

public struct PracticeView: View {
    @State private var practiceMode: PracticeMode = .flashcards
    @State private var contentType: ContentType = .kanji
    @StateObject private var kanjiDataManager = KanjiDataManager()
    @StateObject private var phraseDataManager = PhraseDataManager()
    @StateObject private var progressManager = UserProgressManager()
    
    // Enum chế độ luyện tập
    enum PracticeMode: String, CaseIterable {
        case flashcards = "Flashcards"
        case quiz = "Quiz"
        case writing = "Viết tay"
        
        var icon: String {
            switch self {
            case .flashcards: return "rectangle.stack"
            case .quiz: return "questionmark.circle"
            case .writing: return "pencil"
            }
        }
    }
    
    // Enum loại nội dung
    enum ContentType: String, CaseIterable {
        case kanji = "Kanji"
        case phrases = "Câu giao tiếp"
        
        var icon: String {
            switch self {
            case .kanji: return "character.book.closed"
            case .phrases: return "text.bubble"
            }
        }
    }
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Bộ chọn chế độ và nội dung
                VStack(spacing: 16) {
                    // Bộ chọn chế độ luyện tập
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chế độ luyện tập")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(PracticeMode.allCases, id: \.self) { mode in
                                    ModeChip(
                                        title: mode.rawValue,
                                        icon: mode.icon,
                                        isSelected: practiceMode == mode
                                    ) {
                                        practiceMode = mode
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Bộ chọn loại nội dung
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nội dung")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            ForEach(ContentType.allCases, id: \.self) { type in
                                ContentTypeChip(
                                    title: type.rawValue,
                                    icon: type.icon,
                                    isSelected: contentType == type
                                ) {
                                    contentType = type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .background(Color(.systemGray6))
                
                // Nội dung luyện tập
                practiceContentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Luyện tập")
        }
    }
    
    // View nội dung luyện tập
    @ViewBuilder
    private var practiceContentView: some View {
        switch practiceMode {
        case .flashcards:
            FlashcardPracticeView(contentType: contentType)
        case .quiz:
            QuizPracticeView(contentType: contentType)
        case .writing:
            if contentType == .kanji {
                WritingPracticeView()
            } else {
                UnavailableFeatureView(
                    title: "Luyện viết tay",
                    message: "Tính năng này chỉ khả dụng cho Kanji"
                )
            }
        }
    }
}

// Component chip chế độ
struct ModeChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.accentColor : Color(.systemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 2)
        }
    }
}

// Component chip loại nội dung
struct ContentTypeChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.accentColor : Color(.systemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2)
        }
    }
}

// View tính năng không khả dụng
struct UnavailableFeatureView: View {
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Các View luyện tập cụ thể

// View luyện tập flashcard
struct FlashcardPracticeView: View {
    let contentType: PracticeView.ContentType
    @State private var currentIndex = 0
    @State private var showAnswer = false
    @State private var isFlipped = false
    
    // Dữ liệu mẫu cho flashcard
    private let sampleKanji = [
        ("水", "みず", "nước"),
        ("火", "ひ", "lửa"),
        ("木", "き", "cây"),
        ("金", "きん", "vàng"),
        ("土", "つち", "đất")
    ]
    
    private let samplePhrases = [
        ("こんにちは", "Xin chào", "Lời chào thông dụng"),
        ("ありがとう", "Cảm ơn", "Lời cảm ơn cơ bản"),
        ("すみません", "Xin lỗi", "Lời xin lỗi lịch sự"),
        ("はじめまして", "Rất vui được gặp", "Lời chào khi gặp lần đầu")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Thanh tiến độ
            ProgressView(value: Float(currentIndex + 1), total: Float(currentData.count))
                .padding(.horizontal)
            
            Text("\(currentIndex + 1) / \(currentData.count)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Flashcard
            flashcardView
                .onTapGesture {
                    withAnimation(.spring()) {
                        showAnswer.toggle()
                        isFlipped.toggle()
                    }
                }
            
            Spacer()
            
            // Nút điều khiển
            HStack(spacing: 20) {
                Button("Trước") {
                    previousCard()
                }
                .disabled(currentIndex == 0)
                
                Button(showAnswer ? "Ẩn đáp án" : "Hiện đáp án") {
                    withAnimation(.spring()) {
                        showAnswer.toggle()
                        isFlipped.toggle()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Tiếp") {
                    nextCard()
                }
                .disabled(currentIndex >= currentData.count - 1)
            }
            .padding()
        }
        .padding()
    }
    
    // View flashcard với hiệu ứng lật
    @ViewBuilder
    private var flashcardView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 8)
                .frame(height: 300)
            
            VStack(spacing: 16) {
                if contentType == .kanji {
                    let kanji = sampleKanji[currentIndex]
                    if !showAnswer {
                        // Mặt trước - hiển thị kanji
                        Text(kanji.0)
                            .font(.system(size: 80, weight: .bold))
                    } else {
                        // Mặt sau - hiển thị đọc âm và nghĩa
                        VStack(spacing: 12) {
                            Text(kanji.1)
                                .font(.title)
                                .foregroundColor(.blue)
                            Text(kanji.2)
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    let phrase = samplePhrases[currentIndex]
                    if !showAnswer {
                        // Mặt trước - hiển thị tiếng Nhật
                        Text(phrase.0)
                            .font(.title)
                            .fontWeight(.semibold)
                    } else {
                        // Mặt sau - hiển thị nghĩa và ghi chú
                        VStack(spacing: 12) {
                            Text(phrase.1)
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text(phrase.2)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .padding(.horizontal)
    }
    
    // Dữ liệu hiện tại dựa trên loại nội dung
    private var currentData: [Any] {
        contentType == .kanji ? sampleKanji : samplePhrases
    }
    
    // Chuyển đến thẻ trước
    private func previousCard() {
        if currentIndex > 0 {
            withAnimation {
                currentIndex -= 1
                showAnswer = false
                isFlipped = false
            }
        }
    }
    
    // Chuyển đến thẻ tiếp theo
    private func nextCard() {
        if currentIndex < currentData.count - 1 {
            withAnimation {
                currentIndex += 1
                showAnswer = false
                isFlipped = false
            }
        }
    }
}

// View luyện tập quiz
struct QuizPracticeView: View {
    let contentType: PracticeView.ContentType
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showResult = false
    @State private var score = 0
    
    // Câu hỏi mẫu cho kanji
    private let kanjiQuestions = [
        QuizQuestion(
            question: "Kanji này đọc là gì: 水",
            options: ["みず", "ひ", "き", "つち"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "Nghĩa của kanji 火 là gì?",
            options: ["nước", "lửa", "cây", "đất"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "Kanji nào có nghĩa là 'cây'?",
            options: ["水", "火", "木", "金"],
            correctAnswer: 2
        )
    ]
    
    // Câu hỏi mẫu cho cụm từ
    private let phraseQuestions = [
        QuizQuestion(
            question: "こんにちは có nghĩa là gì?",
            options: ["Cảm ơn", "Xin chào", "Xin lỗi", "Tạm biệt"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "Cách nói 'Cảm ơn' trong tiếng Nhật?",
            options: ["こんにちは", "ありがとう", "すみません", "はじめまして"],
            correctAnswer: 1
        )
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            if !showResult {
                // Giao diện quiz
                quizView
            } else {
                // Giao diện kết quả
                resultView
            }
        }
        .padding()
    }
    
    // Giao diện quiz
    @ViewBuilder
    private var quizView: some View {
        // Thanh tiến độ
        ProgressView(value: Float(currentQuestionIndex + 1), total: Float(currentQuestions.count))
        
        Text("\(currentQuestionIndex + 1) / \(currentQuestions.count)")
            .font(.caption)
            .foregroundColor(.secondary)
        
        Spacer()
        
        // Câu hỏi
        VStack(spacing: 20) {
            Text(currentQuestions[currentQuestionIndex].question)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()
            
            // Các lựa chọn
            VStack(spacing: 12) {
                ForEach(0..<currentQuestions[currentQuestionIndex].options.count, id: \.self) { index in
                    Button(action: {
                        selectedAnswer = index
                    }) {
                        HStack {
                            Text(currentQuestions[currentQuestionIndex].options[index])
                                .font(.body)
                                .foregroundColor(selectedAnswer == index ? .white : .primary)
                            Spacer()
                        }
                        .padding()
                        .background(selectedAnswer == index ? Color.accentColor : Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
            }
        }
        
        Spacer()
        
        // Nút xác nhận
        Button("Xác nhận") {
            checkAnswer()
        }
        .buttonStyle(.borderedProminent)
        .disabled(selectedAnswer == nil)
    }
    
    // Giao diện kết quả
    @ViewBuilder
    private var resultView: some View {
        VStack(spacing: 20) {
            Image(systemName: score >= Int(Float(currentQuestions.count) * 0.7) ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(score >= Int(Float(currentQuestions.count) * 0.7) ? .green : .red)
            
            Text("Kết quả")
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(score) / \(currentQuestions.count)")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text(score >= Int(Float(currentQuestions.count) * 0.7) ? "Xuất sắc!" : "Cần cố gắng thêm!")
                .font(.headline)
                .foregroundColor(score >= Int(Float(currentQuestions.count) * 0.7) ? .green : .orange)
            
            Spacer()
            
            Button("Làm lại") {
                resetQuiz()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // Câu hỏi hiện tại dựa trên loại nội dung
    private var currentQuestions: [QuizQuestion] {
        contentType == .kanji ? kanjiQuestions : phraseQuestions
    }
    
    // Kiểm tra đáp án
    private func checkAnswer() {
        if let selectedAnswer = selectedAnswer, selectedAnswer == currentQuestions[currentQuestionIndex].correctAnswer {
            score += 1
        }
        
        if currentQuestionIndex < currentQuestions.count - 1 {
            // Chuyển câu tiếp theo
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    currentQuestionIndex += 1
                    selectedAnswer = nil
                }
            }
        } else {
            // Hiển thị kết quả
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showResult = true
                }
            }
        }
    }
    
    // Reset quiz
    private func resetQuiz() {
        withAnimation {
            currentQuestionIndex = 0
            selectedAnswer = nil
            showResult = false
            score = 0
        }
    }
}

// Model cho câu hỏi quiz
struct QuizQuestion {
    let question: String
    let options: [String]
    let correctAnswer: Int
}

// View luyện tập viết tay
struct WritingPracticeView: View {
    @State private var currentKanjiIndex = 0
    @State private var strokePaths: [Path] = []
    @State private var currentPath = Path()
    @State private var showHint = false
    
    // Danh sách kanji để luyện viết
    private let practiceKanji = [
        ("一", "いち", "số một"),
        ("二", "に", "số hai"),
        ("三", "さん", "số ba"),
        ("人", "ひと", "người"),
        ("大", "だい", "lớn")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Thông tin kanji hiện tại
            VStack(spacing: 8) {
                Text("Luyện viết: \(practiceKanji[currentKanjiIndex].0)")
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack {
                    Text("Đọc: \(practiceKanji[currentKanjiIndex].1)")
                    Spacer()
                    Text("Nghĩa: \(practiceKanji[currentKanjiIndex].2)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Khu vực vẽ
            ZStack {
                // Nền lưới
                Rectangle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(Color(.systemBackground))
                
                // Đường gợi ý (nếu bật)
                if showHint {
                    Text(practiceKanji[currentKanjiIndex].0)
                        .font(.system(size: 120))
                        .foregroundColor(.blue.opacity(0.3))
                }
                
                // Nét vẽ của người dùng
                ForEach(0..<strokePaths.count, id: \.self) { index in
                    strokePaths[index]
                        .stroke(Color.black, lineWidth: 3)
                }
                
                // Nét đang vẽ
                currentPath
                    .stroke(Color.black, lineWidth: 3)
            }
            .frame(height: 300)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let point = value.location
                        if value.translation == .zero {
                            // Bắt đầu nét mới
                            currentPath = Path()
                            currentPath.move(to: point)
                        } else {
                            // Tiếp tục nét hiện tại
                            currentPath.addLine(to: point)
                        }
                    }
                    .onEnded { _ in
                        // Kết thúc nét, thêm vào danh sách
                        strokePaths.append(currentPath)
                        currentPath = Path()
                    }
            )
            .padding(.horizontal)
            
            // Nút điều khiển
            HStack(spacing: 20) {
                Button("Gợi ý") {
                    showHint.toggle()
                }
                
                Button("Xóa") {
                    clearDrawing()
                }
                
                Button("Tiếp theo") {
                    nextKanji()
                }
                .buttonStyle(.borderedProminent)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // Xóa bản vẽ
    private func clearDrawing() {
        withAnimation {
            strokePaths.removeAll()
            currentPath = Path()
        }
    }
    
    // Chuyển kanji tiếp theo
    private func nextKanji() {
        withAnimation {
            currentKanjiIndex = (currentKanjiIndex + 1) % practiceKanji.count
            clearDrawing()
            showHint = false
        }
    }
}
