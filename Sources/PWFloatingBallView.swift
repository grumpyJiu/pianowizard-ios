import SwiftUI

// ============================================================
// Floating Ball — gradient circle, positioned top-right
// ============================================================

@available(iOS 14.0, *)
struct PWFloatingBallView: View {
    let onTap: () -> Void
    let onDrag: (CGFloat, CGFloat) -> Void

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [PWTheme.purple, PWTheme.pink]),
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 2, y: 3)

            // Music note icon
            Image(systemName: "music.note")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
        }
        .onTapGesture { onTap() }
        .gesture(
            DragGesture()
                .onChanged { value in
                    onDrag(value.translation.width, value.translation.height)
                }
        )
    }
}
