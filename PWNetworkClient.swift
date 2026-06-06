import Foundation

// ============================================================
// Network Client — communicates with PianoWizard server
// ============================================================

@available(iOS 14.0, *)
class PWNetworkClient {
    static let shared = PWNetworkClient()
    private let baseURL = "http://8.138.140.159:5000"

    struct SongListResponse: Codable {
        let ok: Bool
        let total: Int
        let songs: [PWServerSong]
    }

    func fetchSongList(query: String = "", page: Int = 1) async -> [PWServerSong] {
        var urlStr = "\(baseURL)/api/song/list?page=\(page)&per_page=500"
        if !query.isEmpty {
            urlStr += "&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
        }

        guard let url = URL(string: urlStr) else { return [] }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(SongListResponse.self, from: data)
            return response.songs
        } catch {
            print("[PWNetwork] fetch error: \(error)")
            return []
        }
    }

    func fetchPopularSongs() async -> [PWServerSong] {
        guard let url = URL(string: "\(baseURL)/api/song/popular") else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(SongListResponse.self, from: data)
            return response.songs
        } catch {
            return []
        }
    }

    func verifyCard(key: String, deviceId: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/api/card/verify") else { return false }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["key": key, "device_id": deviceId]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return json["ok"] as? Bool ?? false
            }
        } catch {}
        return false
    }

    func downloadSong(fileName: String) async -> String? {
        guard let encoded = fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/api/song/download?file=\(encoded)") else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
