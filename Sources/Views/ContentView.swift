import SwiftUI

public struct ContentView: View {
    @StateObject private var kanjiDataManager = KanjiDataManager()
    @StateObject private var phraseDataManager = PhraseDataManager()
    @StateObject private var progressManager = UserProgressManager()
    @StateObject private var audioManager = AudioManager()
    
    public init() {}
    
    public var body: some View {
        TabView {
            KanjiListView()
                .tabItem {
                    Label("Kanji", systemImage: "character.book.closed")
                }
                .environmentObject(kanjiDataManager)
                .environmentObject(progressManager)
            
            PhrasesView()
                .tabItem {
                    Label("Giao tiếp", systemImage: "text.bubble")
                }
                .environmentObject(phraseDataManager)
                .environmentObject(progressManager)
                .environmentObject(audioManager)
            
            PracticeView()
                .tabItem {
                    Label("Luyện tập", systemImage: "pencil")
                }
                .environmentObject(kanjiDataManager)
                .environmentObject(phraseDataManager)
                .environmentObject(progressManager)
            
            ProfileView()
                .tabItem {
                    Label("Hồ sơ", systemImage: "person")
                }
                .environmentObject(progressManager)
                .environmentObject(kanjiDataManager)
                .environmentObject(phraseDataManager)
        }
        .accentColor(.red)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
