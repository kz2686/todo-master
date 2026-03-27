import SwiftUI

// MARK: - Glass card modifier

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.white.opacity(0.06))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.35), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 18) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Glass section (labelled card for forms)

struct GlassSection<Content: View>: View {
    var title: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.45))
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .padding(.leading, 4)
            }
            content
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()
        }
    }
}

// MARK: - Gradient accent color

extension Color {
    static let accentPink   = Color(red: 1.0, green: 0.17, blue: 0.34)
    static let accentPurple = Color(red: 0.55, green: 0.18, blue: 0.92)
    static let accentOrange = Color(red: 1.0, green: 0.55, blue: 0.05)
}

extension LinearGradient {
    static let pinkPurple = LinearGradient(
        colors: [.accentPink, .accentPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
