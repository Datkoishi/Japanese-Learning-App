import SwiftUI

public struct PhrasesView: View {
    @StateObject private var phraseDataManager = PhraseDataManager()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var progressManager = UserProgressManager()
    
    @State private var selectedCategory: PhraseCategory? = nil
    @State private var searchText = ""
    @State private var showingCategoryDetail = false
    
    var filteredPhrases: [Phrase] {
        var phrases = phraseDataManager.phrases
        
        if let category = selectedCategory {
            phrases = phraseDataManager.getPhrasesByCategory(category)
        }
        
        if !searchText.isEmpty {
            phrases = phraseDataManager.searchPhrases(searchText)
        }
        
        return phrases
    }
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category selector
                categorySelector
                
                // Phrases list
                if filteredPhrases.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "Không tìm thấy câu giao tiếp",
                        subtitle: "Thử thay đổi danh mục hoặc từ khóa tìm kiếm"
                    )
                } else {
                    phrasesList
                }
            }
            .navigationTitle("Câu giao tiếp")
            .searchable(text: $searchText, prompt: "Tìm kiếm câu giao tiếp...")
        }
    }
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All categories button
                CategoryChip(
                    title: "Tất cả",
                    icon: "list.bullet",
                    color: .gray,
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                // Individual category buttons
                ForEach(PhraseCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        color: category.color,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var phrasesList: some View {
        List {
            ForEach(filteredPhrases) { phrase in
                NavigationLink(destination: PhraseDetailView(phrase: phrase)) {
                    PhraseRow(phrase: phrase) {
                        audioManager.playAudio(for: phrase.japanese)
                    } onBookmark: {
                        phraseDataManager.toggleBookmark(for: phrase.id)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct PhraseRow: View {
    let phrase: Phrase
    let onPlayAudio: () -> Void
    let onBookmark: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(phrase.japanese)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(phrase.romaji)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(phrase.meaning)
                    .font(.body)
                    .foregroundColor(.primary)
                
                if !phrase.notes.isEmpty {
                    Text(phrase.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                HStack(spacing: 8) {
                    // Category badge
                    Text(phrase.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(phrase.category.color.opacity(0.2))
                        .foregroundColor(phrase.category.color)
                        .cornerRadius(8)
                    
                    // Difficulty badge
                    Text(phrase.difficulty.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(phrase.difficulty.color.opacity(0.2))
                        .foregroundColor(phrase.difficulty.color)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    // Mastery stars
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < phrase.masteryLevel ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.system(size: 10))
                        }
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button(action: onPlayAudio) {
                    Image(systemName: "speaker.wave.2")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
                
                Button(action: onBookmark) {
                    Image(systemName: phrase.isBookmarked ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(phrase.isBookmarked ? .red : .gray)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

public struct PhraseDetailView: View {
    let phrase: Phrase
    @StateObject private var phraseDataManager = PhraseDataManager()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var progressManager = UserProgressManager()
    @State private var isShowingMeaning = false
    
    public init(phrase: Phrase) {
        self.phrase = phrase
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with Japanese phrase
                phraseHeaderView
                
                // Audio controls
                audioControlsView
                
                // Meaning section
                meaningSection
                
                // Context and usage
                contextSection
                
                // Practice buttons
                practiceButtonsSection
                
                // Progress section
                progressSection
            }
            .padding()
        }
        .navigationTitle("Chi tiết câu")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    phraseDataManager.toggleBookmark(for: phrase.id)
                }) {
                    Image(systemName: phrase.isBookmarked ? "heart.fill" : "heart")
                        .foregroundColor(phrase.isBookmarked ? .red : .gray)
                }
            }
        }
        .onAppear {
            phraseDataManager.updatePhraseProgress(for: phrase.id)
            progressManager.updateStudyTime(3) // 3 minutes for viewing
        }
    }
    
    private var phraseHeaderView: some View {
        VStack(spacing: 16) {
            Text(phrase.japanese)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text(phrase.kana)
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text(phrase.romaji)
                .font(.title3)
                .italic()
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                // Category badge
                HStack(spacing: 4) {
                    Image(systemName: phrase.category.icon)
                        .font(.caption)
                    Text(phrase.category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(phrase.category.color.opacity(0.2))
                .foregroundColor(phrase.category.color)
                .cornerRadius(12)
                
                // Difficulty badge
                Text(phrase.difficulty.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(phrase.difficulty.color.opacity(0.2))
                    .foregroundColor(phrase.difficulty.color)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var audioControlsView: some View {
        VStack(spacing: 12) {
            Button(action: {
                audioManager.playAudio(for: phrase.japanese)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: audioManager.isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                        .font(.title2)
                    
                    Text(audioManager.isPlaying ? "Đang phát..." : "Nghe phát âm")
                        .font(.headline)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(audioManager.isPlaying)
            
            Text("Bấm để nghe cách phát âm chuẩn")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var meaningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation {
                    isShowingMeaning.toggle()
                }
            }) {
                HStack {
                    Text(isShowingMeaning ? "Ẩn nghĩa" : "Hiện nghĩa")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: isShowingMeaning ? "eye.slash" : "eye")
                        .font(.title3)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .cornerRadius(12)
            }
            
            if isShowingMeaning {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nghĩa:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(phrase.meaning)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.accentColor)
                    }
                    
                    if !phrase.notes.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ghi chú:")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(phrase.notes)
                                .font(.body)
                                .italic()
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 4)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
    
    private var contextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ngữ cảnh sử dụng")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                ContextRow(
                    icon: "clock",
                    title: "Thời gian",
                    description: getTimeContext()
                )
                
                ContextRow(
                    icon: "person.2",
                    title: "Đối tượng",
                    description: getFormalityLevel()
                )
                
                ContextRow(
                    icon: "location",
                    title: "Địa điểm",
                    description: getLocationContext()
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4)
    }
    
    private var practiceButtonsSection: some View {
        VStack(spacing: 12) {
            Text("Đánh giá mức độ hiểu")
                .font(.headline)
            
            HStack(spacing: 12) {
                Button(action: {
                    phraseDataManager.updatePhraseProgress(for: phrase.id, masteryChange: -1)
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                        Text("Cần ôn tập")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    phraseDataManager.updatePhraseProgress(for: phrase.id, masteryChange: 0)
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                        Text("Bình thường")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    phraseDataManager.updatePhraseProgress(for: phrase.id, masteryChange: 1)
                    progressManager.updatePhraseProgress()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                        Text("Đã thuộc")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(12)
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
                HStack {
                    Text("Mức độ thành thạo")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < phrase.masteryLevel ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.system(size: 16))
                        }
                    }
                }
                
                HStack {
                    Text("Số lần luyện tập")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(phrase.practiced) lần")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                if let lastPracticed = phrase.lastPracticed {
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
    
    private func getTimeContext() -> String {
        switch phrase.category {
        case .greetings:
            if phrase.japanese.contains("おはよう") {
                return "Buổi sáng (6:00 - 10:00)"
            } else if phrase.japanese.contains("こんにちは") {
                return "Buổi chiều (10:00 - 18:00)"
            } else if phrase.japanese.contains("こんばんは") {
                return "Buổi tối (18:00 - 22:00)"
            }
            return "Mọi thời điểm"
        default:
            return "Mọi thời điểm"
        }
    }
    
    private func getFormalityLevel() -> String {
        if phrase.notes.contains("Lịch sự") || phrase.japanese.contains("ございます") {
            return "Lịch sự, trang trọng"
        } else if phrase.notes.contains("Thân mật") {
            return "Thân mật, bạn bè"
        }
        return "Trung tính"
    }
    
    private func getLocationContext() -> String {
        switch phrase.category {
        case .greetings:
            return "Mọi nơi"
        case .thanks:
            return "Khi nhận được giúp đỡ"
        case .apologies:
            return "Khi cần xin lỗi"
        case .questions:
            return "Khi cần hỏi thông tin"
        case .responses:
            return "Khi trả lời câu hỏi"
        case .daily:
            return "Cuộc sống hàng ngày"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ContextRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}
