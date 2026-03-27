import SwiftUI

struct PriorityBadge: View {
    let priority: Priority

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: priority.symbol)
            Text(priority.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(priority.color.opacity(0.18))
        .foregroundColor(priority.color)
        .overlay(
            Capsule()
                .stroke(priority.color.opacity(0.4), lineWidth: 0.5)
        )
        .clipShape(Capsule())
    }
}
