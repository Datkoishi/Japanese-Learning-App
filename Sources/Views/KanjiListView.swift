import SwiftUI

public struct KanjiListView: View {
    @StateObject private var kanjiDataManager = KanjiDataManager()
    @StateObject private var progressManager = UserProgressManager()
    @State private var searchText = ""
    @State private var selectedFilter: KanjiFilter = .all
    @State private var showingFilterSheet = false
    
    enum KanjiFilter: String, CaseIterable {
        case all = "Tất cả"
        case favorites = "Yêu thích"
        case recent = "Gần đây"
        case mastered = "Đã thuộc"
        case learning = "Đang học"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .favorites: return "heart.fill"
            case .recent: return "clock.fill"
            case .mastered: return "checkmark.circle.fill"
            case .learning: return "book.fill"
            }
        }
    }
    
    var filteredKanji: [Kanji] {
        var kanji = kanjiDataManager.kanjiList
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .favorites:
            kanji = kanjiDataManager.favoriteKanji
        case .recent:
            kanji = kanjiDataManager.recentlyStudied
        case .mastered:
            kanji = kanjiDataManager.getKanjiByMasteryLevel(5)
        case .learning:
            kanji = kanji.filter { $0.masteryLevel > 0 && $0.masteryLevel < 5 }
        }
        
        // Apply search
        if !searchText.isEmpty {
            kanji = kanji.filter { kanji in
                kanji.character.contains(searchText) ||
                kanji.meaning.localizedCaseInsensitiveContains(searchText) ||
                kanji.romaji.localizedCaseInsensitiveContains(searchText) ||
                kanji.kana.contains(searchText)
            }
        }
        
        return kanji
    }
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(KanjiFilter.allCases, id: \.self) { filter in
                            FilterChip(
                                title: filter.rawValue,
                                icon: filter.icon,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Kanji grid
                if filteredKanji.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "Không tìm thấy Kanji",
                        subtitle: "Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm"
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(filteredKanji) { kanji in
                                NavigationLink(destination: KanjiDetailView(kanji: kanji)) {
                                    KanjiCard(kanji: kanji) {
                                        kanjiDataManager.toggleBookmark(for: kanji.id)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Kanji Nhân Tư")
            .searchable(text: $searchText, prompt: "Tìm kiếm Kanji...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilterSheet = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheet(selectedFilter: $selectedFilter)
        }
    }
}

struct KanjiCard: View {
    let kanji: Kanji
    let onBookmarkTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button(action: onBookmarkTap) {
                    Image(systemName: kanji.isBookmarked ? "heart.fill" : "heart")
                        .foregroundColor(kanji.isBookmarked ? .red : .gray)
                        .font(.system(size: 16))
                }
            }
            
            Text(kanji.character)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 4) {
                Text(kanji.meaning)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(kanji.romaji)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Mastery level
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Image(systemName: index < kanji.masteryLevel ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.system(size: 10))
                }
            }
            
            // Progress indicator
            if kanji.practiced > 0 {
                Text("Đã luyện \(kanji.practiced) lần")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(height: 180)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct FilterSheet: View {
    @Binding var selectedFilter: KanjiListView.KanjiFilter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(KanjiListView.KanjiFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: filter.icon)
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            
                            Text(filter.rawValue)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Bộ lọc")
            .navigationBarItems(trailing: Button("Xong") {
                dismiss()
            })
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
