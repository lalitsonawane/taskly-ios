import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.dueDate) private var allTasks: [TaskItem]
    @Query(filter: #Predicate<TaskList> { $0.isInbox == true }) private var inboxLists: [TaskList]

    @State private var showingAddTask = false
    @State private var selectedTask: TaskItem?

    private var startOfToday: Date {
        Calendar.current.startOfDay(for: .now)
    }

    private var endOfToday: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfToday) ?? startOfToday
    }

    private var overdueTasks: [TaskItem] {
        allTasks.filter { task in
            guard !task.isCompleted, let due = task.dueDate else { return false }
            return due < startOfToday
        }
        .sorted { ($0.dueDate ?? .distantPast) < ($1.dueDate ?? .distantPast) }
    }

    private var dueTodayTasks: [TaskItem] {
        allTasks.filter { task in
            guard !task.isCompleted, let due = task.dueDate else { return false }
            return due >= startOfToday && due < endOfToday
        }
        .sorted { lhs, rhs in
            if lhs.priority != rhs.priority {
                return priorityRank(lhs.priority) > priorityRank(rhs.priority)
            }
            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
    }

    private var isEmpty: Bool {
        overdueTasks.isEmpty && dueTodayTasks.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if isEmpty {
                    EmptyStateView(
                        systemImage: "sun.max",
                        title: "You're all clear",
                        message: "Nothing due today. Add a task with a due date to see it here.",
                        actionTitle: "Add your first task",
                        action: { showingAddTask = true }
                    )
                } else {
                    List {
                        if !overdueTasks.isEmpty {
                            Section("Overdue") {
                                ForEach(overdueTasks) { task in
                                    taskRow(task)
                                }
                                .onDelete { indexSet in
                                    deleteTasks(overdueTasks, at: indexSet)
                                }
                            }
                        }

                        if !dueTodayTasks.isEmpty {
                            Section("Due Today") {
                                ForEach(dueTodayTasks) { task in
                                    taskRow(task)
                                }
                                .onDelete { indexSet in
                                    deleteTasks(dueTodayTasks, at: indexSet)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add task")
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddEditTaskView(
                    task: nil,
                    defaultList: inboxLists.first,
                    defaultDueDate: .now
                )
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task)
            }
        }
    }

    @ViewBuilder
    private func taskRow(_ task: TaskItem) -> some View {
        TaskRowView(task: task, showListName: true)
            .contentShape(Rectangle())
            .onTapGesture { selectedTask = task }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    delete(task)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .swipeActions(edge: .leading) {
                Button {
                    rescheduleToTomorrow(task)
                } label: {
                    Label("Tomorrow", systemImage: "calendar.badge.plus")
                }
                .tint(AppTheme.accent)
            }
    }

    private func deleteTasks(_ tasks: [TaskItem], at offsets: IndexSet) {
        for index in offsets {
            delete(tasks[index])
        }
    }

    private func delete(_ task: TaskItem) {
        withAnimation {
            modelContext.delete(task)
            HapticFeedback.warning()
        }
    }

    private func rescheduleToTomorrow(_ task: TaskItem) {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)
        task.dueDate = tomorrow
        HapticFeedback.selection()
    }

    private func priorityRank(_ priority: TaskPriority) -> Int {
        switch priority {
        case .none: return 0
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        }
    }
}
