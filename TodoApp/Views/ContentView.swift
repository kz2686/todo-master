import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: TodoStore

    init() {
        let tab = UITabBarAppearance()
        tab.configureWithTransparentBackground()
        tab.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
        UITabBar.appearance().tintColor = UIColor(red: 1, green: 0.17, blue: 0.34, alpha: 1)
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.35)
    }

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max.fill") }

            AllTodosView()
                .tabItem { Label("All", systemImage: "list.bullet") }

            CompletedView()
                .tabItem { Label("Done", systemImage: "checkmark.circle.fill") }
        }
    }
}
