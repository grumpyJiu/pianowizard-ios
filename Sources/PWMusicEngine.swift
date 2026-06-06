import Foundation
import UIKit

// ============================================================
// Auto-play Engine
// Uses PTFakeMetaTouch via ObjC bridge to simulate piano taps
// Matches Android MusicPlayer logic
// ============================================================

@available(iOS 14.0, *)
class PWMusicEngine {

    private var isPlaying = false
    private var isPaused = false
    private var playTask: Task<Void, Never>?

    // Key layout points (set during coordinate setup)
    var keyPoints: [CGPoint] = []
    var keyOffset: Int = 0

    // Callbacks
    var onProgress: ((Double, Double) -> Void)?  // elapsed, total ms
    var onStopped: (() -> Void)?
    var onPaused: (() -> Void)?
    var onResumed: (() -> Void)?

    // ============================================================
    // Play a song from server (JSON format)
    // ============================================================
    func playServerSong(notes: [(time: Int, keyIndex: Int)], bpm: Int, speedRate: Float = 1.0) {
        stop()

        let baseTime = 60000.0 / Double(bpm) / Double(speedRate) // ms per beat
        let totalMs = Double(notes.last?.time ?? 0)

        playTask = Task {
            isPlaying = true
            isPaused = false

            for note in notes {
                guard !Task.isCancelled else { break }

                // Wait for pause signal
                while isPaused && !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }

                let delayMs = Double(note.time) / 1000.0 // Convert to seconds
                try? await Task.sleep(nanoseconds: UInt64(delayMs * 1_000_000_000))

                guard !Task.isCancelled else { break }

                // Tap the key
                let keyIdx = note.keyIndex + keyOffset
                if keyIdx >= 0 && keyIdx < keyPoints.count {
                    let point = keyPoints[keyIdx]
                    await MainActor.run {
                        PWTouchSimulatorWrapper.tap(at: point)
                    }
                }

                // Update progress
                let elapsed = Double(note.time)
                let progress = totalMs > 0 ? elapsed / totalMs : 0
                await MainActor.run {
                    self.onProgress?(elapsed, totalMs)
                    PWAppState.shared.player.progress = Float(progress)
                    PWAppState.shared.player.currentTime = self.formatTime(elapsed)
                    PWAppState.shared.player.totalTime = self.formatTime(totalMs)
                }
            }

            await MainActor.run {
                self.isPlaying = false
                self.onStopped?()
            }
        }
    }

    // ============================================================
    // Play from iOS compact format (reference format)
    // Format: "g4();t4();t3();..." with note names like c4,d4,...,c6
    // ============================================================
    func playCompactSong(notation: String, speedRate: Float = 1.0) {
        stop()

        // Parse notation
        let notes = parseCompactNotation(notation)
        playTask = Task {
            isPlaying = true
            for note in notes {
                guard !Task.isCancelled else { break }
                while isPaused && !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }
                try? await Task.sleep(nanoseconds: UInt64(note.delay * 1_000_000))
                if let idx = note.keyIndex, idx >= 0 && idx < keyPoints.count {
                    await MainActor.run {
                        PWTouchSimulatorWrapper.tap(at: keyPoints[idx])
                    }
                }
            }
            await MainActor.run { self.isPlaying = false; self.onStopped?() }
        }
    }

    // Map note names to key indices (c4=0, d4=1, ..., c6=14)
    private let noteMap: [String: Int] = {
        let names = ["c4","d4","e4","f4","g4","a4","b4","c5","d5","e5","f5","g5","a5","b5","c6"]
        return Dictionary(uniqueKeysWithValues: names.enumerated().map { ($1, $0) })
    }()

    private func parseCompactNotation(_ notation: String) -> [(delay: TimeInterval, keyIndex: Int?)] {
        var result: [(TimeInterval, Int?)] = []
        let parts = notation.components(separatedBy: ";").filter { !$0.isEmpty }
        for part in parts {
            if part.hasPrefix("t") {
                // Wait: t4 = 400ms, t3 = 300ms, etc.
                let numStr = part.dropFirst().replacingOccurrences(of: "();", with: "").replacingOccurrences(of: "()", with: "")
                if let delay = Double(numStr) {
                    result.append((delay * 0.1, nil))
                }
            } else {
                // Note: g4() = play note g4
                let noteStr = part.replacingOccurrences(of: "();", with: "").replacingOccurrences(of: "()", with: "")
                if let idx = noteMap[noteStr] {
                    result.append((0.1, idx))
                }
            }
        }
        return result
    }

    func pause() { isPaused = true; onPaused?() }
    func resume() { isPaused = false; onResumed?() }
    func stop() { playTask?.cancel(); isPlaying = false; isPaused = false }

    private func formatTime(_ ms: Double) -> String {
        let totalSec = Int(ms / 1000)
        return String(format: "%02d:%02d", totalSec / 60, totalSec % 60)
    }
}

// ============================================================
// Touch Simulator Wrapper (ObjC bridge)
// ============================================================
struct PWTouchSimulatorWrapper {
    static func tap(at point: CGPoint) {
        // Uses the ObjC PWTouchSimulator class (PWPluginBridge.m)
        // which wraps PTFakeMetaTouch
        let simulator = NSClassFromString("PWTouchSimulator") as? NSObject.Type
        simulator?.perform(NSSelectorFromString("tapAtPoint:"), with: NSValue(cgPoint: point))
    }
}
