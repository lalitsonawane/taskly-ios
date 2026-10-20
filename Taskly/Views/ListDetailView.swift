import SwiftUI
import SwiftData

struct ListDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var list: TaskList

    @State private var showingAddTask = false
    @State private var selectedTask: TaskItem?
    @State private var showCompleted = false

    private var openTasks: [TaskItem] {
        list.tasks
            .filter { !$0.isCompleted }
            .sorted { lhs, rhs in
                switch (lhs.dueDate, rhs.dueDate) {
                case let (l?, r?):
                    if l != r { return l < r }
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                case (nil, nil):
                    break
                }
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
    }

    private var completedTasks: [TaskItem] {
        list.tasks
            .filter({ $0.isCompleted })
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }

    var body: some View {
        Group {
            if openTasks.isEmpty && completedTasks.isEmpty {
                EmptyStateView(
                    systemImage: "checklist",
                    title: "No tasks yet",
                    message: "Add your first task to this list.",
                    actionTitle: "Add your first task",
                    action: { showingAddTask = true }
                )
            } else {
                List {
                    Section {
                        ForEach(openTasks) { task in
                            taskRow(task)
                        }
                        .onDelete(perform: deleteOpen)
                    }

                    if !completedTasks.isEmpty {
                        Section {
                            DisclosureGroup(isExpanded: $showCompleted) {
                                ForEach(completedTasks) { task in
                                    taskRow(task)
                                }
                                .onDelete(perform: deleteCompleted)
                            } label: {
                                Text("Completed (\(completedTasks.count))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.large)
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
            AddEditTaskView(task: nil, defaultList: list, defaultDueDate: nil)
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
    }

    @ViewBuilder
    private func taskRow(_ task: TaskItem) -> some View {
        TaskRowView(task: task, showListName: false)
            .contentShape(Rectangle())
            .onTapGesture { selectedTask = task }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    delete(task)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
    }

    private func deleteOpen(at offsets: IndexSet) {
        for index in offsets {
            delete(openTasks[index])
        }
    }

    private func deleteCompleted(at offsets: IndexSet) {
        for index in offsets {
            delete(completedTasks[index])
        }
    }

    private func delete(_ task: TaskItem) {
        withAnimation {
            modelContext.delete(task)
            HapticFeedback.warning()
        }
    }
}
