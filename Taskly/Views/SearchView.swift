import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var allTasks: [TaskItem]

    @State private var query = ""
    @State private var selectedTask: TaskItem?

    private var filteredTasks: [TaskItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return allTasks.filter { task in
            task.title.localizedCaseInsensitiveContains(trimmed)
                || task.notes.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    EmptyStateView(
                        systemImage: "magnifyingglass",
                        title: "Search tasks",
                        message: "Find tasks by title or notes across all lists."
                    )
                } else if filteredTasks.isEmpty {
                    EmptyStateView(
                        systemImage: "magnifyingglass",
                        title: "No matches",
                        message: "Nothing matches "\(query.trimmingCharacters(in: .whitespacesAndNewlines))"."
                    )
                } else {
                    List {
                        ForEach(filteredTasks) { task in
                            TaskRowView(task: task, showListName: true)
                                .contentShape(Rectangle())
                                .onTapGesture { selectedTask = task }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            modelContext.delete(task)
                                            HapticFeedback.warning()
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Search")
            .searchable(text: $query, prompt: "Title or notes")
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task)
            }
        }
    }
}
