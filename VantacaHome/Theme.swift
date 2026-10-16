import SwiftUI

extension Color {
    static let vBlue = Color(red: 0.13, green: 0.55, blue: 0.96)
    static let vNavy = Color(red: 0.11, green: 0.24, blue: 0.40)
    static let vTeal = Color(red: 0.16, green: 0.47, blue: 0.62)
    static let vGreen = Color(red: 0.42, green: 0.71, blue: 0.27)
    static let vBackground = Color(red: 0.94, green: 0.96, blue: 0.98)
    static let vBorder = Color(red: 0.82, green: 0.85, blue: 0.89)
    static let vText = Color(red: 0.13, green: 0.16, blue: 0.20)
    static let vSubtext = Color(red: 0.38, green: 0.42, blue: 0.47)
}

struct VantacaLogo: View {
    var size: CGFloat = 64

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.18)
            .fill(Color(red: 0.93, green: 0.94, blue: 0.86))
            .frame(width: size, height: size)
            .overlay(
                VStack(spacing: size * 0.03) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: size * 0.42, weight: .black))
                        .foregroundStyle(LinearGradient(colors: [.vNavy, .vTeal], startPoint: .leading, endPoint: .trailing))
                    Image(systemName: "house.fill")
                        .font(.system(size: size * 0.32, weight: .bold))
                        .foregroundStyle(Color.vGreen)
                }
                .offset(y: -size * 0.02)
            )
    }
}

struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}

struct PrimaryButton: View {
    let title: String
    var isLoading = false
    var disabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading { ProgressView().tint(.white) } else { Text(title).fontWeight(.semibold) }
            }
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(disabled ? Color.vBlue.opacity(0.4) : Color.vBlue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(disabled || isLoading)
    }
}

struct FieldLabel: View {
    let text: String
    var body: some View {
        Text(text).font(.subheadline.weight(.semibold)).foregroundStyle(Color.vText)
    }
}

struct BoxedField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .frame(height: 46)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.vBorder))
    }
}

extension View {
    func boxed() -> some View { modifier(BoxedField()) }
}

extension Double {
    var usd: String { formatted(.currency(code: "USD").locale(Locale(identifier: "en_US"))) }
}
