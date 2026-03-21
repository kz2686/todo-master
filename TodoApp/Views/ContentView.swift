import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: TodoStore

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            AllTodosView()
                .tabItem {
                    Label("All", systemImage: "list.bullet")
                }

            CompletedView()
                .tabItem {
                    Label("Done", systemImage: "checkmark.circle.fill")
                }
        }
    }
}
