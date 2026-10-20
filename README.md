# Taskly

Personal task manager for iOS - lists, due dates, priority, and search. Built with **SwiftUI + SwiftData** (iOS 17+). No accounts, no backend.

## Features (MVP)

- **Today** - overdue + due today, checkbox complete with haptic, swipe to delete or reschedule to tomorrow
- **Lists** - seeded **Inbox** (non-deletable) + create / rename / delete your own lists
- **Search** - filter by title or notes across all tasks
- **Tasks** - title, notes, optional due date, priority (none / low / medium / high), list membership
- Light-first UI with a soft teal accent, SF Symbols only, Dynamic Type-friendly rows

## Requirements

- macOS with **Xcode 15+** (iOS 17 SDK)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

Cloud agents author sources + `project.yml`; you generate the `.xcodeproj` on your Mac.

## Open in Xcode

```bash
git clone https://github.com/lalitsonawane/taskly-ios.git
cd taskly-ios
git checkout lalit_cursor/taskly-mvp-9dad   # or main once merged

# Generate the Xcode project (required once, or after project.yml changes)
xcodegen generate

open Taskly.xcodeproj
```

In Xcode:

1. Select the **Taskly** scheme
2. Choose an **iPhone Simulator** (iOS 17+)
3. Press **Run** (⌘R)

### Without XcodeGen

If you prefer not to install XcodeGen, create a new iOS App in Xcode named **Taskly** (SwiftUI, SwiftData, iOS 17), then replace the generated sources with the `Taskly/` folder from this repo and ensure `Assets.xcassets` is in the target's Copy Bundle Resources.

## Project layout

```
Taskly/
  TasklyApp.swift
  Models/
    TaskItem.swift
    TaskList.swift
  Views/
    RootTabView.swift
    TodayView.swift
    ListsView.swift
    ListDetailView.swift
    SearchView.swift
    TaskRowView.swift
    TaskDetailView.swift
    AddEditTaskView.swift
    EmptyStateView.swift
  Theme/
    AppTheme.swift
  Resources/
    Assets.xcassets
project.yml          # XcodeGen spec
README.md
```

## Manual verification checklist

Run through this in Simulator after first launch:

- [ ] **Inbox** appears under Lists (cannot delete it)
- [ ] Create a new list -> rename it -> delete it
- [ ] Add a task with title, notes, due date, and priority
- [ ] Open the task -> edit -> save
- [ ] From **Today**, see overdue / due-today tasks
- [ ] Tap the checkbox -> task completes with haptic; strikethrough appears
- [ ] Swipe a task -> **Delete** removes it; leading swipe **Tomorrow** moves due date
- [ ] **Search** finds tasks by title and by notes
- [ ] Empty states show when Today is clear and when a list has no tasks
- [ ] Dynamic Type: Settings -> Accessibility -> Larger Text - labels still readable

## Out of scope (MVP)

Reminders / notifications, recurring tasks, tags, sync, widgets, collaboration.

## License

MIT - personal project scaffold.
