import Foundation
import SwiftUI

public struct Phrase: Identifiable, Codable, Hashable {
    public var id = UUID()
    public let japanese: String
    public let kana: String
    public let romaji: String
    public let meaning: String
    public let notes: String
    public let category: PhraseCategory
    public let difficulty: PhraseDifficulty
    
    // Progress tracking
    public var practiced: Int = 0
    public var masteryLevel: Int = 0 // 0-5 stars
    public var lastPracticed: Date?
    public var isBookmarked: Bool = false
    
    public init(
        japanese: String,
        kana: String,
        romaji: String,
        meaning: String,
        notes: String = "",
        category: PhraseCategory,
        difficulty: PhraseDifficulty = .beginner
    ) {
        self.japanese = japanese
        self.kana = kana
        self.romaji = romaji
        self.meaning = meaning
        self.notes = notes
        self.category = category
        self.difficulty = difficulty
    }
}

public enum PhraseCategory: String, Codable, CaseIterable {
    case greetings = "Chào hỏi"
    case thanks = "Cảm ơn"
    case apologies = "Xin lỗi"
    case questions = "Câu hỏi"
    case responses = "Trả lời"
    case daily = "Hàng ngày"
    
    public var icon: String {
        switch self {
        case .greetings: return "hand.wave"
        case .thanks: return "heart"
        case .apologies: return "exclamationmark.bubble"
        case .questions: return "questionmark.bubble"
        case .responses: return "bubble.left.and.bubble.right"
        case .daily: return "calendar"
        }
    }
    
    public var color: Color {
        switch self {
        case .greetings: return .blue
        case .thanks: return .green
        case .apologies: return .orange
        case .questions: return .purple
        case .responses: return .pink
        case .daily: return .teal
        }
    }
}

public enum PhraseDifficulty: String, Codable, CaseIterable {
    case beginner = "Cơ bản"
    case intermediate = "Trung cấp"
    case advanced = "Nâng cao"
    
    public var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

public class PhraseDataManager: ObservableObject {
    @Published public var phrases: [Phrase] = []
    @Published public var favoritePhrases: [Phrase] = []
    @Published public var recentlyStudied: [Phrase] = []
    
    public init() {
        loadPhraseData()
    }
    
    public func loadPhraseData() {
        phrases = [
            // Greetings
            Phrase(
                japanese: "こんにちは",
                kana: "こんにちは",
                romaji: "Konnichiwa",
                meaning: "Xin chào (buổi chiều)",
                category: .greetings
            ),
            Phrase(
                japanese: "おはようございます",
                kana: "おはようございます",
                romaji: "Ohayō gozaimasu",
                meaning: "Chào buổi sáng",
                notes: "Lịch sự hơn おはよう",
                category: .greetings
            ),
            Phrase(
                japanese: "こんばんは",
                kana: "こんばんは",
                romaji: "Konbanwa",
                meaning: "Chào buổi tối",
                category: .greetings
            ),
            Phrase(
                japanese: "さようなら",
                kana: "さようなら",
                romaji: "Sayōnara",
                meaning: "Tạm biệt",
                category: .greetings
            ),
            
            // Thanks
            Phrase(
                japanese: "ありがとう",
                kana: "ありがとう",
                romaji: "Arigatō",
                meaning: "Cảm ơn",
                notes: "Thân mật",
                category: .thanks
            ),
            Phrase(
                japanese: "ありがとうございます",
                kana: "ありがとうございます",
                romaji: "Arigatō gozaimasu",
                meaning: "Cảm ơn (lịch sự)",
                category: .thanks
            ),
            
            // Apologies
            Phrase(
                japanese: "ごめんなさい",
                kana: "ごめんなさい",
                romaji: "Gomennasai",
                meaning: "Xin lỗi",
                notes: "Thân mật",
                category: .apologies
            ),
            Phrase(
                japanese: "すみません",
                kana: "すみません",
                romaji: "Sumimasen",
                meaning: "Xin lỗi, xin phép",
                notes: "Lịch sự, dùng nhiều mục đích",
                category: .apologies
            ),
            
            // Responses
            Phrase(
                japanese: "はい",
                kana: "はい",
                romaji: "Hai",
                meaning: "Vâng",
                category: .responses
            ),
            Phrase(
                japanese: "いいえ",
                kana: "いいえ",
                romaji: "Iie",
                meaning: "Không",
                category: .responses
            ),
            Phrase(
                japanese: "わかりました",
                kana: "わかりました",
                romaji: "Wakarimashita",
                meaning: "Tôi hiểu rồi",
                category: .responses
            ),
            Phrase(
                japanese: "わかりません",
                kana: "わかりません",
                romaji: "Wakarimasen",
                meaning: "Tôi không hiểu",
                category: .responses
            ),
            
            // Questions
            Phrase(
                japanese: "おねがいします",
                kana: "おねがいします",
                romaji: "Onegaishimasu",
                meaning: "Làm ơn, xin hãy",
                notes: "Câu xin phép, yêu cầu",
                category: .questions
            ),
            Phrase(
                japanese: "おげんきですか",
                kana: "おげんきですか",
                romaji: "Ogenki desu ka",
                meaning: "Bạn có khỏe không?",
                notes: "Câu hỏi thăm hỏi",
                category: .questions
            ),
            
            // Daily
            Phrase(
                japanese: "はじめまして",
                kana: "はじめまして",
                romaji: "Hajimemashite",
                meaning: "Rất hân hạnh được gặp",
                notes: "Dùng khi giới thiệu",
                category: .daily
            )
        ]
    }
    
    public func updatePhraseProgress(for id: UUID, practiced: Bool = true, masteryChange: Int = 0) {
        if let index = phrases.firstIndex(where: { $0.id == id }) {
            if practiced {
                phrases[index].practiced += 1
                phrases[index].lastPracticed = Date()
                
                // Add to recently studied if not already there
                if !recentlyStudied.contains(where: { $0.id == id }) {
                    recentlyStudied.insert(phrases[index], at: 0)
                    if recentlyStudied.count > 10 {
                        recentlyStudied.removeLast()
                    }
                }
            }
            
            phrases[index].masteryLevel += masteryChange
            phrases[index].masteryLevel = min(max(phrases[index].masteryLevel, 0), 5)
        }
    }
    
    public func toggleBookmark(for id: UUID) {
        if let index = phrases.firstIndex(where: { $0.id == id }) {
            phrases[index].isBookmarked.toggle()
            
            if phrases[index].isBookmarked {
                favoritePhrases.append(phrases[index])
            } else {
                favoritePhrases.removeAll { $0.id == id }
            }
        }
    }
    
    public func getPhrasesByCategory(_ category: PhraseCategory) -> [Phrase] {
        return phrases.filter { $0.category == category }
    }
    
    public func getPhrasesByDifficulty(_ difficulty: PhraseDifficulty) -> [Phrase] {
        return phrases.filter { $0.difficulty == difficulty }
    }
    
    public func getRandomPhrase(excluding: [UUID] = []) -> Phrase? {
        let availablePhrases = phrases.filter { !excluding.contains($0.id) }
        return availablePhrases.randomElement()
    }
    
    public func searchPhrases(_ searchText: String) -> [Phrase] {
        if searchText.isEmpty {
            return phrases
        }
        
        return phrases.filter { phrase in
            phrase.japanese.localizedCaseInsensitiveContains(searchText) ||
            phrase.romaji.localizedCaseInsensitiveContains(searchText) ||
            phrase.meaning.localizedCaseInsensitiveContains(searchText) ||
            phrase.kana.localizedCaseInsensitiveContains(searchText)
        }
    }
}
