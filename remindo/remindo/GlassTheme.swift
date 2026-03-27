//
//  GlassTheme.swift
//  remindo
//

import SwiftUI

// MARK: - Background

struct GlassBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.04, blue: 0.12)

            // Pink blob — top right
            Ellipse()
                .fill(Color(red: 1.0, green: 0.17, blue: 0.34).opacity(0.55))
                .frame(width: 380, height: 320)
                .blur(radius: 90)
                .offset(x: 130, y: -280)

            // Purple blob — center left
            Circle()
                .fill(Color(red: 0.55, green: 0.18, blue: 0.92).opacity(0.5))
                .frame(width: 320)
                .blur(radius: 90)
                .offset(x: -90, y: 60)

            // Orange blob — bottom
            Ellipse()
                .fill(Color(red: 1.0, green: 0.55, blue: 0.05).opacity(0.35))
                .frame(width: 280, height: 200)
                .blur(radius: 80)
                .offset(x: 70, y: 400)
        }
        .ignoresSafeArea()
    }
}

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

// MARK: - Accent colors

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

// MARK: - Priority & category glass colors

extension Todo.Priority {
    var glassColor: Color {
        switch self {
        case .none:   return .white.opacity(0.25)
        case .low:    return Color(red: 0.19, green: 0.82, blue: 0.61)
        case .medium: return Color(red: 1.0,  green: 0.75, blue: 0.0)
        case .high:   return Color(red: 1.0,  green: 0.27, blue: 0.34)
        }
    }
}

extension Todo.Category {
    var glassColor: Color {
        switch self {
        case .personal: return Color(red: 0.0, green: 0.8, blue: 0.9)
        case .work:     return Color(red: 0.7, green: 0.3, blue: 1.0)
        }
    }
}
