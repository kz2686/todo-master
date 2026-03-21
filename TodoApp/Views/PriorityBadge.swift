import SwiftUI

struct PriorityBadge: View {
    let priority: Priority

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: priority.symbol)
            Text(priority.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .font(.caption)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(priority.color.opacity(0.12))
        .foregroundColor(priority.color)
        .clipShape(Capsule())
    }
}
