import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskList.sortOrder) private var lists: [TaskList]
    @State private var hasSeeded = false

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max")
                }

            ListsView()
                .tabItem {
                    Label("Lists", systemImage: "list.bullet")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
        .task {
            seedInboxIfNeeded()
        }
    }

    private func seedInboxIfNeeded() {
        guard !hasSeeded else { return }
        hasSeeded = true
        let inboxExists = lists.contains(where: { $0.isInbox })
        guard !inboxExists else { return }
        let inbox = TaskList(name: "Inbox", isInbox: true, sortOrder: 0)
        modelContext.insert(inbox)
        try? modelContext.save()
    }
}
