# TodoApp — iOS

A simple, local-only iOS todo/reminder app built with SwiftUI.

## Features

- **Today view** — shows todos with no due date + todos due today
- **All Todos view** — all incomplete todos, sorted by priority then date
- **Done (Last 7 Days)** — review what you've completed recently
- **Optional due date** — pick a date or leave it undated
- **Optional priority** — High / Medium / Low with color-coded badges
- **Notes** — add context, links, or follow-up thoughts to any todo
- **Persistent storage** — saved to `UserDefaults` (no internet required)
- **Swipe to delete** — swipe left on any row

## Setup in Xcode

1. Open Xcode → **File → New → Project**
2. Choose **iOS → App**
3. Set:
   - Product Name: `TodoApp`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Uncheck "Include Tests" if you want to keep it minimal
4. Click **Next**, choose a save location, then **Create**
5. Delete the auto-generated `ContentView.swift` (move to trash)
6. In Xcode's project navigator, right-click the `TodoApp` folder → **Add Files to "TodoApp"…**
7. Navigate to this `TodoApp/` folder and add **all files**, keeping "Create groups" selected

That's it — build and run on a simulator or device.

## File Structure

```
TodoApp/
├── TodoApp.swift           # App entry point
├── Models/
│   └── Todo.swift          # Todo & Priority types
├── ViewModels/
│   └── TodoStore.swift     # State management + UserDefaults persistence
└── Views/
    ├── ContentView.swift   # Tab bar root
    ├── TodayView.swift     # Today tab
    ├── AllTodosView.swift  # All tab
    ├── CompletedView.swift # Done tab
    ├── TodoRowView.swift   # Row for active todos
    ├── CompletedRowView.swift  # Row for completed todos
    ├── TodoDetailView.swift    # Detail/read view
    ├── AddEditTodoView.swift   # Add + edit form
    └── PriorityBadge.swift    # Reusable priority indicator
```

## Data Model

```swift
struct Todo {
    var id: UUID
    var title: String
    var notes: String         // follow-up thoughts, links, context
    var dueDate: Date?        // optional
    var priority: Priority?   // optional: .low | .medium | .high
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
}
```
