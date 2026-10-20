import SwiftUI
import SwiftData

struct AddEditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskList.sortOrder) private var lists: [TaskList]

    var task: TaskItem?
    var defaultList: TaskList?
    var defaultDueDate: Date?

    @State private var title = ""
    @State private var notes = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var priority: TaskPriority = .none
    @State private var selectedListID: UUID?

    private var isEditing: Bool { task != nil }

    private var sortedLists: [TaskList] {
        lists.sorted { lhs, rhs in
            if lhs.isInbox != rhs.isInbox { return lhs.isInbox && !rhs.isInbox }
            return lhs.sortOrder < rhs.sortOrder
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title, axis: .vertical)
                        .lineLimit(1...3)
                        .accessibilityLabel("Task title")

                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                        .accessibilityLabel("Notes")
                }

                Section("List") {
                    Picker("List", selection: $selectedListID) {
                        ForEach(sortedLists) { list in
                            Text(list.name).tag(Optional(list.id))
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("Due Date") {
                    Toggle("Has due date", isOn: $hasDueDate.animation())
                    if hasDueDate {
                        DatePicker(
                            "Due",
                            selection: $dueDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(AppTheme.accent)
                    }
                }

                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases) { value in
                            Label(value.displayName, systemImage: value.systemImage)
                                .tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                        .fontWeight(.semibold)
                }
            }
            .onAppear(perform: load)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func load() {
        if let task {
            title = task.title
            notes = task.notes
            priority = task.priority
            selectedListID = task.list?.id
            if let due = task.dueDate {
                hasDueDate = true
                dueDate = due
            }
        } else {
            selectedListID = defaultList?.id ?? lists.first(where: { $0.isInbox })?.id
            if let defaultDueDate {
                hasDueDate = true
                dueDate = defaultDueDate
            }
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let selectedList = lists.first { $0.id == selectedListID }
            ?? lists.first(where: { $0.isInbox })

        if let task {
            task.title = trimmedTitle
            task.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            task.priority = priority
            task.dueDate = hasDueDate ? Calendar.current.startOfDay(for: dueDate) : nil
            task.list = selectedList
        } else {
            let item = TaskItem(
                title: trimmedTitle,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                dueDate: hasDueDate ? Calendar.current.startOfDay(for: dueDate) : nil,
                priority: priority,
                list: selectedList
            )
            modelContext.insert(item)
        }

        HapticFeedback.selection()
        dismiss()
    }
}
