import SwiftUI

// ============================================================
// Card Info Panel — shows card key, device ID, status
// 360×280pt, matched to Android version
// ============================================================

@available(iOS 14.0, *)
struct PWCardInfoView: View {
    let onClose: () -> Void
    let onDrag: (CGFloat, CGFloat) -> Void

    @StateObject private var state = PWAppState.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title
            HStack {
                Text("卡密信息")
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(PWTheme.textPrimary)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color(hex: 0xFFE60012)))
                }
            }

            Spacer().frame(height: 10)

            // Status badge
            HStack {
                Text(state.isVerified ? "已激活" : "未验证")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(state.isVerified ? Color(hex: 0xFF155724) : Color(hex: 0xFF856404))
                Spacer()
                Text(state.isVerified ? "有效" : "待验证")
                    .font(.system(size: 12))
                    .foregroundColor(PWTheme.textSecondary)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(state.isVerified ? Color(hex: 0xFFD4EDDA) : Color(hex: 0xFFFFF3CD))
            )

            Spacer().frame(height: 8)

            InfoRow(label: "卡密", value: state.cardKey.isEmpty ? "未输入" : state.cardKey)
            InfoRow(label: "到期时间", value: state.isVerified ? "永久有效" : "试用1小时")
            InfoRow(label: "设备ID", value: UIDevice.current.identifierForVendor?.uuidString.prefix(12).description ?? "unknown")

            Spacer().frame(height: 8)

            Button(action: {}) {
                Text("更换卡密")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(PWTheme.purple)
                    )
            }
        }
        .padding(16)
        .frame(width: 320, height: 260)
        .background(
            RoundedRectangle(cornerRadius: 34)
                .fill(PWTheme.glassBg)
                .shadow(color: .black.opacity(0.15), radius: 18, x: 0, y: 4)
        )
        .gesture(DragGesture().onChanged { v in onDrag(v.translation.width, v.translation.height) })
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(PWTheme.textSecondary)
                .frame(width: 60, alignment: .leading)
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(PWTheme.textPrimary)
                .lineLimit(2)
            Spacer()
        }
        .padding(.vertical, 3)
    }
}
