import SwiftUI

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
