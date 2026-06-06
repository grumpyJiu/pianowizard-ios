import SwiftUI

// ============================================================
// PianoWizard Theme & Colors — matched to Android Compose version
// ============================================================

struct PWTheme {
    // ── Main Panel Colors ───────────────────────────────
    static let panelBg          = Color(hex: 0xF0ECECEC)  // 94% translucent
    static let cardBg           = Color(hex: 0xFAFFFFFF)  // 98% white
    static let textPrimary      = Color(hex: 0xFF1C1C1E)
    static let textSecondary    = Color(hex: 0xFF7A7A7A)
    static let textTertiary     = Color(hex: 0xFFC7C7CC)

    // ── Accent Colors ────────────────────────────────────
    static let purple           = Color(hex: 0xFFA855F7)
    static let pink             = Color(hex: 0xFFF43F5E)
    static let blue             = Color(hex: 0xFF4DA3FF)
    static let green            = Color(hex: 0xFF34C759)
    static let primary          = Color(hex: 0xFF7C3AED)

    // ── Glass Player Colors ──────────────────────────────
    static let glassBg          = Color(hex: 0xB3E8F0FE)  // 70% blue-white
    static let glassBorder      = Color(hex: 0x40FFFFFF)
    static let glassHighlight   = Color(hex: 0x30FFFFFF)
    static let accentBlue       = Color(hex: 0xFF4A7DFF)
    static let darkBlueGray     = Color(hex: 0xFF2C3E50)
    static let speedCapsuleBg   = Color(hex: 0x40FFFFFF)

    // ── Search / Tab Colors ──────────────────────────────
    static let searchBg         = Color(hex: 0xFFF5F5F5)
    static let tabBg            = Color(hex: 0xFFD0D0D0)
}

// ── Color Hex Initializer ─────────────────────────────────
extension Color {
    init(hex: UInt64) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        let a = Double((hex >> 24) & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
