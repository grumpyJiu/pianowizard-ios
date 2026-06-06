import SwiftUI

// ============================================================
// Glassmorphism Player Card — iOS replica of Android version
// 350×130dp → ~350×130pt on iOS
// ============================================================

@available(iOS 14.0, *)
struct PWPlayerView: View {
    let onClose: () -> Void
    let onDrag: (CGFloat, CGFloat) -> Void

    @StateObject private var state = PWAppState.shared
    @State private var speedText = "1.0x"

    var body: some View {
        HStack(spacing: 0) {
            // ── Left: Album Art ───────────────────────
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: 0xFF667EEA), Color(hex: 0xFF764BA2)]),
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 62, height: 62)
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 2))
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)

                Image(systemName: "music.note")
                    .font(.system(size: 26))
                    .foregroundColor(.white)
            }

            Spacer().frame(width: 10)

            // ── Right: Info + Controls ────────────────
            VStack(spacing: 0) {
                // Song name
                Text(state.player.songName.isEmpty ? "未选择歌曲" : state.player.songName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(PWTheme.darkBlueGray)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer().frame(height: 6)

                // Progress
                HStack(spacing: 6) {
                    Text(state.player.currentTime)
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xFF94A3B8))

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: 0xFFE2E8F0))
                                .frame(height: 2.5)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: 0xFF3B82F6))
                                .frame(width: geo.size.width * CGFloat(state.player.progress), height: 2.5)
                        }
                    }
                    .frame(height: 2.5)

                    Text(state.player.totalTime)
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xFF94A3B8))
                }

                Spacer().frame(height: 8)

                // Control buttons
                HStack(spacing: 10) {
                    // Prev
                    GlassButton(icon: "backward.fill", size: 34) {}

                    // Play/Pause
                    GlassButton(
                        icon: state.player.isPlaying && !state.player.isPaused ? "pause.fill" : "play.fill",
                        size: 42, iconSize: 24
                    ) {}

                    // Next
                    GlassButton(icon: "forward.fill", size: 34) {}

                    // Favorite
                    Button(action: {}) {
                        Image(systemName: state.player.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(state.player.isFavorite ? Color(hex: 0xFFFF4D4F) : Color(hex: 0xFF94A3B8))
                    }

                    Spacer()

                    // Speed capsules
                    SpeedCapsule("-0.1") {}
                    SpeedCapsule("还原") {}
                    Spacer().frame(width: 4)
                    Text(speedText)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: 0xFF64748B))
                    Spacer().frame(width: 4)
                    SpeedCapsule("+0.1") {}
                    SpeedCapsule("+0.2") {}
                }
                .padding(.leading, 8)
            }
        }
        .padding(14)
        .background(
            // Glass background
            RoundedRectangle(cornerRadius: 28)
                .fill(PWTheme.glassBg)
                .overlay(
                    // Top highlight
                    VStack {
                        LinearGradient(
                            gradient: Gradient(colors: [PWTheme.glassHighlight, .clear]),
                            startPoint: .top, endPoint: .bottom
                        )
                        .frame(height: 50)
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(PWTheme.glassBorder, lineWidth: 0.5)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
        // Close button overlay
        .overlay(
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Color(hex: 0xFFFF4D4F)))
                    .shadow(color: .black.opacity(0.15), radius: 2)
            }
            .padding(4),
            alignment: .topTrailing
        )
        .gesture(
            DragGesture()
                .onChanged { value in
                    onDrag(value.translation.width, value.translation.height)
                }
        )
    }
}

// ── Glass Circle Button ──────────────────────────────────
struct GlassButton: View {
    let icon: String
    var size: CGFloat = 34
    var iconSize: CGFloat = 18
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: iconSize))
                .foregroundColor(PWTheme.accentBlue)
                .frame(width: size, height: size)
                .background(Circle().fill(Color.white.opacity(0.3)))
                .overlay(Circle().stroke(PWTheme.accentBlue.opacity(0.5), lineWidth: 1.5))
        }
    }
}

// ── Speed Capsule ────────────────────────────────────────
struct SpeedCapsule: View {
    let label: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(hex: 0xFF5A6B7F))
                .padding(.horizontal, 8)
                .frame(height: 26)
                .background(Capsule().fill(PWTheme.speedCapsuleBg))
        }
    }
}
