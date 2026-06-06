import SwiftUI
import Combine

// ============================================================
// Data Models — matched to Android version
// ============================================================

struct PWServerSong: Codable, Identifiable {
    let id: Int
    let title: String
    let fileName: String
    let keyCount: Int
    let playCount: Int
    let priority: Int
    let uploadedAt: String

    enum CodingKeys: String, CodingKey {
        case id, title
        case fileName = "file_name"
        case keyCount = "key_count"
        case playCount = "play_count"
        case priority
        case uploadedAt = "uploaded_at"
    }
}

struct PWSongRowState: Identifiable {
    let id = UUID()
    let path: String
    let name: String
    var isFavorite: Bool
    var playCount: Int
    var keyCount: Int
}

enum PWSongSortType: String, CaseIterable {
    case all = "全部"
    case popular = "热门"
    case newest = "最新"
    case favorites = "收藏"
}

struct PWPlayerState {
    var songName: String = ""
    var isPlaying: Bool = false
    var isPaused: Bool = false
    var isFavorite: Bool = false
    var currentTime: String = "00:00"
    var totalTime: String = "00:00"
    var progress: Float = 0
    var speedText: String = "1.0x"
}

struct PWMainPanelState {
    var songs: [PWSongRowState] = []
    var currentTab: PWSongSortType = .all
    var searchQuery: String = ""
    var nowPlaying: String? = nil
    var nowPlayingPath: String? = nil
    var isPlaying: Bool = false
    var isPaused: Bool = false
    var totalSongCount: Int = 0
}

// ============================================================
// App State (ObservableObject, shared across all windows)
// ============================================================
@available(iOS 14.0, *)
class PWAppState: ObservableObject {
    static let shared = PWAppState()

    @Published var mainPanel = PWMainPanelState()
    @Published var player = PWPlayerState()
    @Published var serverSongs: [PWServerSong] = []
    @Published var serverTotal: Int = 0
    @Published var isVerified: Bool = false
    @Published var cardKey: String = ""

    private let defaults = UserDefaults(suiteName: "com.pianowizard.tweak")!

    var isFavorite: (String) -> Bool = { _ in false }
    var toggleFavorite: (String) -> Void = { _ in }

    func updateMainPanel() {
        let tab = mainPanel.currentTab
        let songs: [PWSongRowState]

        if tab == .favorites {
            songs = serverSongs
                .filter { isFavorite($0.fileName) }
                .map { PWSongRowState(
                    path: $0.fileName, name: $0.title,
                    isFavorite: true, playCount: $0.playCount, keyCount: $0.keyCount
                )}
        } else {
            songs = serverSongs.map { s in
                PWSongRowState(
                    path: s.fileName, name: s.title,
                    isFavorite: isFavorite(s.fileName),
                    playCount: s.playCount, keyCount: s.keyCount
                )
            }
        }

        mainPanel.songs = songs
        mainPanel.totalSongCount = tab == .favorites ? songs.count : serverTotal
    }
}
