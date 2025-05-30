import SwiftUI

public struct ProfileView: View {
    @StateObject private var progressManager = UserProgressManager()
    @StateObject private var kanjiDataManager = KanjiDataManager()
    @StateObject private var phraseDataManager = PhraseDataManager()
    
    @State private var isEditingProfile = false
    @State private var showingSettings = false
    @State private var showingAchievements = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeaderView
                    
                    // Quick stats
                    quickStatsView
                    
                    // Progress overview
                    progressOverviewView
                    
                    // Recent achievements
                    recentAchievementsView
                    
                    // Action buttons
                    actionButtonsView
                }
                .padding()
            }
            .navigationTitle("Hồ sơ")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .sheet(isPresented: $isEditingProfile) {
            EditProfileView(progressManager: progressManager)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementsView(progressManager: progressManager)
        }
    }
    
    private var profileHeaderView: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
            }
            
            // User info
            VStack(spacing: 8) {
                Text(progressManager.username)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Button(action: {
                    isEditingProfile = true
                }) {
                    Text("Chỉnh sửa hồ sơ")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
            }
            
            // Streak indicator
            HStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(progressManager.studyStreak) ngày")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Streak hiện tại")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var quickStatsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Thống kê nhanh")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    icon: "clock.fill",
                    title: "Thời gian học",
                    value: progressManager.formatStudyTime(progressManager.totalStudyTime),
                    color: .green
                )
                
                StatCard(
                    icon: "character.book.closed.fill",
                    title: "Kanji đã học",
                    value: "\(progressManager.totalKanjiLearned)/20",
                    color: .blue
                )
                
                StatCard(
                    icon: "text.bubble.fill",
                    title: "Câu giao tiếp",
                    value: "\(progressManager.totalPhrasesLearned)/15",
                    color: .purple
                )
                
                StatCard(
                    icon: "brain.head.profile",
                    title: "Quiz đã làm",
                    value: "\(progressManager.totalQuizzesTaken)",
                    color: .orange
                )
            }
        }
    }
    
    private var progressOverviewView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tiến độ học tập")
                .font(.headline)
            
            VStack(spacing: 16) {
                ProgressRow(
                    title: "Kanji Nhân Tư",
                    current: progressManager.totalKanjiLearned,
                    total: 20,
                    color: .blue
                )
                
                ProgressRow(
                    title: "Câu giao tiếp cơ bản",
                    current: progressManager.totalPhrasesLearned,
                    total: 15,
                    color: .purple
                )
                
                ProgressRow(
                    title: "Điểm trung bình Quiz",
                    current: Int(progressManager.averageQuizScore * 100),
                    total: 100,
                    color: .orange,
                    suffix: "%"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4)
    }
    
    private var recentAchievementsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Thành tích")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showingAchievements = true
                }) {
                    Text("Xem tất cả")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(progressManager.achievements.prefix(4), id: \.id) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            ActionButton(
                title: "Cài đặt",
                icon: "gear",
                color: .gray
            ) {
                showingSettings = true
            }
            
            ActionButton(
                title: "Chia sẻ ứng dụng",
                icon: "square.and.arrow.up",
                color: .blue
            ) {
                shareApp()
            }
            
            ActionButton(
                title: "Đánh giá ứng dụng",
                icon: "star",
                color: .yellow
            ) {
                rateApp()
            }
        }
    }
    
    private func shareApp() {
        // Implement app sharing
        print("Sharing app...")
    }
    
    private func rateApp() {
        // Implement app rating
        print("Rating app...")
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4)
    }
}

struct ProgressRow: View {
    let title: String
    let current: Int
    let total: Int
    let color: Color
    let suffix: String
    
    init(title: String, current: Int, total: Int, color: Color, suffix: String = "") {
        self.title = title
        self.current = current
        self.total = total
        self.color = color
        self.suffix = suffix
    }
    
    var progress: Double {
        return Double(current) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(current)/\(total)\(suffix)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(y: 1.5)
        }
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.title3)
                    .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            }
            
            Text(achievement.title)
                .font(.caption2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
        }
        .frame(width: 80)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2)
        }
    }
}

struct EditProfileView: View {
    @ObservedObject var progressManager: UserProgressManager
    @Environment(\.dismiss) private var dismiss
    @State private var newUsername: String
    
    init(progressManager: UserProgressManager) {
        self.progressManager = progressManager
        self._newUsername = State(initialValue: progressManager.username)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Thông tin cá nhân")) {
                    TextField("Tên hiển thị", text: $newUsername)
                }
                
                Section(header: Text("Thống kê")) {
                    HStack {
                        Text("Streak hiện tại")
                        Spacer()
                        Text("\(progressManager.studyStreak) ngày")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Tổng thời gian học")
                        Spacer()
                        Text(progressManager.formatStudyTime(progressManager.totalStudyTime))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Chỉnh sửa hồ sơ")
            .navigationBarItems(
                leading: Button("Hủy") {
                    dismiss()
                },
                trailing: Button("Lưu") {
                    progressManager.username = newUsername
                    dismiss()
                }
            )
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isDarkMode = false
    @State private var soundEnabled = true
    @State private var notificationsEnabled = true
    @State private var iCloudSyncEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Giao diện")) {
                    Toggle("Chế độ tối", isOn: $isDarkMode)
                    Toggle("Hiệu ứng âm thanh", isOn: $soundEnabled)
                }
                
                Section(header: Text("Thông báo")) {
                    Toggle("Nhắc nhở học tập hàng ngày", isOn: $notificationsEnabled)
                    Toggle("Thông báo thành tích", isOn: $notificationsEnabled)
                }
                
                Section(header: Text("Dữ liệu")) {
                    Toggle("Đồng bộ iCloud", isOn: $iCloudSyncEnabled)
                    
                    Button("Xóa dữ liệu học tập") {
                        // Show confirmation dialog
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("Thông tin")) {
                    HStack {
                        Text("Phiên bản")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Điều khoản sử dụng") {
                        // Show terms
                    }
                    
                    Button("Chính sách bảo mật") {
                        // Show privacy policy
                    }
                }
            }
            .navigationTitle("Cài đặt")
            .navigationBarItems(trailing: Button("Xong") {
                dismiss()
            })
        }
    }
}

struct AchievementsView: View {
    @ObservedObject var progressManager: UserProgressManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(progressManager.achievements, id: \.id) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding()
            }
            .navigationTitle("Thành tích")
            .navigationBarItems(trailing: Button("Xong") {
                dismiss()
            })
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            }
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            if achievement.isUnlocked {
                Text("✓ Đã mở khóa")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            } else {
                Text("Chưa mở khóa")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(height: 180)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}
