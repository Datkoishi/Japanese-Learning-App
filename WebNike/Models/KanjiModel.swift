import Foundation
import SwiftUI

public struct Kanji: Identifiable, Codable, Hashable {
    public var id = UUID()
    public let character: String
    public let kana: String
    public let romaji: String
    public let meaning: String
    public let example: String
    public let exampleKana: String
    public let exampleRomaji: String
    public let exampleMeaning: String
    public let strokeCount: Int
    public let strokeOrder: [String]
    
    // Progress tracking
    public var practiced: Int = 0
    public var masteryLevel: Int = 0 // 0-5 stars
    public var lastPracticed: Date?
    public var isBookmarked: Bool = false
    
    public init(
        character: String,
        kana: String,
        romaji: String,
        meaning: String,
        example: String,
        exampleKana: String,
        exampleRomaji: String,
        exampleMeaning: String,
        strokeCount: Int,
        strokeOrder: [String] = []
    ) {
        self.character = character
        self.kana = kana
        self.romaji = romaji
        self.meaning = meaning
        self.example = example
        self.exampleKana = exampleKana
        self.exampleRomaji = exampleRomaji
        self.exampleMeaning = exampleMeaning
        self.strokeCount = strokeCount
        self.strokeOrder = strokeOrder
    }
}

public class KanjiDataManager: ObservableObject {
    @Published public var kanjiList: [Kanji] = []
    @Published public var favoriteKanji: [Kanji] = []
    @Published public var recentlyStudied: [Kanji] = []
    
    public init() {
        loadKanjiData()
    }
    
    public func loadKanjiData() {
        kanjiList = [
            Kanji(
                character: "人",
                kana: "ひと",
                romaji: "hito",
                meaning: "người",
                example: "日本人",
                exampleKana: "にほんじん",
                exampleRomaji: "nihonjin",
                exampleMeaning: "người Nhật",
                strokeCount: 2,
                strokeOrder: ["M 30,75 L 50,30 L 70,75", "M 30,45 L 70,45"]
            ),
            Kanji(
                character: "口",
                kana: "くち",
                romaji: "kuchi",
                meaning: "miệng",
                example: "入口",
                exampleKana: "いりぐち",
                exampleRomaji: "iriguchi",
                exampleMeaning: "cửa vào",
                strokeCount: 3,
                strokeOrder: ["M 30,30 L 70,30", "M 70,30 L 70,70", "M 70,70 L 30,70", "M 30,70 L 30,30"]
            ),
            Kanji(
                character: "手",
                kana: "て",
                romaji: "te",
                meaning: "tay",
                example: "手紙",
                exampleKana: "てがみ",
                exampleRomaji: "tegami",
                exampleMeaning: "bức thư",
                strokeCount: 4,
                strokeOrder: ["M 30,30 L 70,30", "M 50,30 L 50,70", "M 30,50 L 70,50", "M 30,70 L 70,70"]
            ),
            Kanji(
                character: "足",
                kana: "あし",
                romaji: "ashi",
                meaning: "chân",
                example: "足りる",
                exampleKana: "たりる",
                exampleRomaji: "tariru",
                exampleMeaning: "đủ",
                strokeCount: 7,
                strokeOrder: []
            ),
            Kanji(
                character: "目",
                kana: "め",
                romaji: "me",
                meaning: "mắt",
                example: "目標",
                exampleKana: "もくひょう",
                exampleRomaji: "mokuhyō",
                exampleMeaning: "mục tiêu",
                strokeCount: 5,
                strokeOrder: []
            ),
            Kanji(
                character: "耳",
                kana: "みみ",
                romaji: "mimi",
                meaning: "tai",
                example: "耳鼻科",
                exampleKana: "じびか",
                exampleRomaji: "jibika",
                exampleMeaning: "tai mũi họng",
                strokeCount: 6,
                strokeOrder: []
            ),
            Kanji(
                character: "心",
                kana: "こころ",
                romaji: "kokoro",
                meaning: "tim",
                example: "心配",
                exampleKana: "しんぱい",
                exampleRomaji: "shinpai",
                exampleMeaning: "lo lắng",
                strokeCount: 4,
                strokeOrder: []
            ),
            Kanji(
                character: "父",
                kana: "ちち",
                romaji: "chichi",
                meaning: "cha",
                example: "父親",
                exampleKana: "ちちおや",
                exampleRomaji: "chichioya",
                exampleMeaning: "bố ruột",
                strokeCount: 4,
                strokeOrder: []
            ),
            Kanji(
                character: "母",
                kana: "はは",
                romaji: "haha",
                meaning: "mẹ",
                example: "母国",
                exampleKana: "ぼこく",
                exampleRomaji: "bokoku",
                exampleMeaning: "nước mẹ đẻ",
                strokeCount: 5,
                strokeOrder: []
            ),
            Kanji(
                character: "女",
                kana: "おんな",
                romaji: "onna",
                meaning: "phụ nữ",
                example: "女性",
                exampleKana: "じょせい",
                exampleRomaji: "josei",
                exampleMeaning: "phụ nữ",
                strokeCount: 3,
                strokeOrder: []
            ),
            Kanji(
                character: "男",
                kana: "おとこ",
                romaji: "otoko",
                meaning: "đàn ông",
                example: "男性",
                exampleKana: "だんせい",
                exampleRomaji: "dansei",
                exampleMeaning: "nam giới",
                strokeCount: 7,
                strokeOrder: []
            ),
            Kanji(
                character: "子",
                kana: "こ",
                romaji: "ko",
                meaning: "con",
                example: "子供",
                exampleKana: "こども",
                exampleRomaji: "kodomo",
                exampleMeaning: "trẻ em",
                strokeCount: 3,
                strokeOrder: []
            ),
            Kanji(
                character: "体",
                kana: "からだ",
                romaji: "karada",
                meaning: "cơ thể",
                example: "体重",
                exampleKana: "たいじゅう",
                exampleRomaji: "taijū",
                exampleMeaning: "cân nặng",
                strokeCount: 7,
                strokeOrder: []
            ),
            Kanji(
                character: "声",
                kana: "こえ",
                romaji: "koe",
                meaning: "giọng",
                example: "声優",
                exampleKana: "せいゆう",
                exampleRomaji: "seiyū",
                exampleMeaning: "diễn viên lồng tiếng",
                strokeCount: 7,
                strokeOrder: []
            ),
            Kanji(
                character: "頭",
                kana: "あたま",
                romaji: "atama",
                meaning: "đầu",
                example: "頭痛",
                exampleKana: "ずつう",
                exampleRomaji: "zutsū",
                exampleMeaning: "nhức đầu",
                strokeCount: 16,
                strokeOrder: []
            ),
            Kanji(
                character: "顔",
                kana: "かお",
                romaji: "kao",
                meaning: "mặt",
                example: "顔色",
                exampleKana: "かおいろ",
                exampleRomaji: "kaoiro",
                exampleMeaning: "sắc mặt",
                strokeCount: 18,
                strokeOrder: []
            ),
            Kanji(
                character: "指",
                kana: "ゆび",
                romaji: "yubi",
                meaning: "ngón tay",
                example: "指輪",
                exampleKana: "ゆびわ",
                exampleRomaji: "yubiwa",
                exampleMeaning: "nhẫn",
                strokeCount: 9,
                strokeOrder: []
            ),
            Kanji(
                character: "背",
                kana: "せ",
                romaji: "se",
                meaning: "lưng",
                example: "背中",
                exampleKana: "せなか",
                exampleRomaji: "senaka",
                exampleMeaning: "lưng",
                strokeCount: 9,
                strokeOrder: []
            ),
            Kanji(
                character: "心臓",
                kana: "しんぞう",
                romaji: "shinzō",
                meaning: "trái tim",
                example: "心臓病",
                exampleKana: "しんぞうびょう",
                exampleRomaji: "shinzōbyō",
                exampleMeaning: "bệnh tim",
                strokeCount: 8,
                strokeOrder: []
            ),
            Kanji(
                character: "骨",
                kana: "ほね",
                romaji: "hone",
                meaning: "xương",
                example: "骨折",
                exampleKana: "こっせつ",
                exampleRomaji: "kossetsu",
                exampleMeaning: "gãy xương",
                strokeCount: 10,
                strokeOrder: []
            )
        ]
    }
    
    public func updateKanjiProgress(for id: UUID, practiced: Bool = true, masteryChange: Int = 0) {
        if let index = kanjiList.firstIndex(where: { $0.id == id }) {
            if practiced {
                kanjiList[index].practiced += 1
                kanjiList[index].lastPracticed = Date()
                
                // Add to recently studied if not already there
                if !recentlyStudied.contains(where: { $0.id == id }) {
                    recentlyStudied.insert(kanjiList[index], at: 0)
                    if recentlyStudied.count > 10 {
                        recentlyStudied.removeLast()
                    }
                }
            }
            
            kanjiList[index].masteryLevel += masteryChange
            kanjiList[index].masteryLevel = min(max(kanjiList[index].masteryLevel, 0), 5)
        }
    }
    
    public func toggleBookmark(for id: UUID) {
        if let index = kanjiList.firstIndex(where: { $0.id == id }) {
            kanjiList[index].isBookmarked.toggle()
            
            if kanjiList[index].isBookmarked {
                favoriteKanji.append(kanjiList[index])
            } else {
                favoriteKanji.removeAll { $0.id == id }
            }
        }
    }
    
    public func getKanjiByMasteryLevel(_ level: Int) -> [Kanji] {
        return kanjiList.filter { $0.masteryLevel == level }
    }
    
    public func getRandomKanji(excluding: [UUID] = []) -> Kanji? {
        let availableKanji = kanjiList.filter { !excluding.contains($0.id) }
        return availableKanji.randomElement()
    }
}
