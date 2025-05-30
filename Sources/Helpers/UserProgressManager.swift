import Foundation
import SwiftUI

public class UserProgressManager: ObservableObject {
    @AppStorage("username") public var username: String = "Học viên"
    @AppStorage("studyStreak") public var studyStreak: Int = 0
    @AppStorage("totalStudyTime") public var totalStudyTime: Int = 0 // in minutes
    @AppStorage("lastStudyDate") public var lastStudyDate: String = ""
    @AppStorage("totalKanjiLearned") public var totalKanjiLearned: Int = 0
    @AppStorage("totalPhrasesLearned") public var totalPhrasesLearned: Int = 0
    @AppStorage("totalQuizzesTaken") public var totalQuizzesTaken: Int = 0
    @AppStorage("averageQuizScore") public var averageQuizScore: Double = 0.0
    
    @Published public var achievements: [Achievement] = []
    
    public init() {
        loadAchievements()
        checkDailyStreak()
    }
    
    private func loadAchievements() {
        achievements = [
            Achievement(
                id: "first_lesson",
                title: "Người mới bắt đầu",
                description: "Hoàn thành bài học đầu tiên",
                icon: "book.fill",
                isUnlocked: totalKanjiLearned > 0 || totalPhrasesLearned > 0
            ),
            Achievement(
                id: "kanji_master_10",
                title: "Thạo 10 Kanji",
                description: "Học thuộc 10 chữ Kanji",
                icon: "target",
                isUnlocked: totalKanjiLearned >= 10
            ),
            Achievement(
                id: "streak_7",
                title: "Streak 7 ngày",
                description: "Học liên tục 7 ngày",
                icon: "flame.fill",
                isUnlocked: studyStreak >= 7
            ),
            Achievement(
                id: "quiz_master",
                title: "Quiz Master",
                description: "Đạt 90% trong quiz",
                icon: "star.fill",
                isUnlocked: averageQuizScore >= 0.9
            ),
            Achievement(
                id: "conversation_master",
                title: "Thạo giao tiếp",
                description: "Học thuộc 15 câu giao tiếp",
                icon: "bubble.left.and.bubble.right.fill",
                isUnlocked: totalPhrasesLearned >= 15
            ),
            Achievement(
                id: "kanji_expert",
                title: "Chuyên gia Kanji",
                description: "Hoàn thành tất cả 20 Kanji",
                icon: "crown.fill",
                isUnlocked: totalKanjiLearned >= 20
            )
        ]
    }
    
    public func updateStudyTime(_ minutes: Int) {
        totalStudyTime += minutes
        updateLastStudyDate()
    }
    
    public func updateKanjiProgress() {
        totalKanjiLearned += 1
        updateLastStudyDate()
        checkAchievements()
    }
    
    public func updatePhraseProgress() {
        totalPhrasesLearned += 1
        updateLastStudyDate()
        checkAchievements()
    }
    
    public func updateQuizScore(_ score: Double) {
        totalQuizzesTaken += 1
        
        // Calculate new average
        let totalScore = averageQuizScore * Double(totalQuizzesTaken - 1) + score
        averageQuizScore = totalScore / Double(totalQuizzesTaken)
        
        updateLastStudyDate()
        checkAchievements()
    }
    
    private func updateLastStudyDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        if lastStudyDate != today {
            lastStudyDate = today
            updateStreak()
        }
    }
    
    private func updateStreak() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let lastDate = formatter.date(from: lastStudyDate) else {
            studyStreak = 1
            return
        }
        
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        
        if calendar.isDate(lastDate, inSameDayAs: yesterday) {
            studyStreak += 1
        } else if !calendar.isDate(lastDate, inSameDayAs: Date()) {
            studyStreak = 1
        }
    }
    
    private func checkDailyStreak() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        if lastStudyDate.isEmpty {
            studyStreak = 0
        } else if lastStudyDate != today {
            let calendar = Calendar.current
            if let lastDate = formatter.date(from: lastStudyDate) {
                let daysBetween = calendar.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
                if daysBetween > 1 {
                    studyStreak = 0
                }
            }
        }
    }
    
    private func checkAchievements() {
        loadAchievements() // Reload to update unlock status
    }
    
    public func formatStudyTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) phút"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

public struct Achievement: Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let icon: String
    public let isUnlocked: Bool
    
    public init(id: String, title: String, description: String, icon: String, isUnlocked: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.isUnlocked = isUnlocked
    }
}
