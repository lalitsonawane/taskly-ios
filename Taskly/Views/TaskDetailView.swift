import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var task: TaskItem

    @State private var showingEdit = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(alignment: .top, spacing: 12) {
                        Button {
                            withAnimation(AppTheme.checkboxSpring) {
                                task.isCompleted.toggle()
                                task.completedAt = task.isCompleted ? .now : nil
                                HapticFeedback.taskCompleted()
                            }
                        } label: {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.largeTitle)
                                .foregroundStyle(task.isCompleted ? AppTheme.accent : Color.secondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(task.isCompleted ? "Mark incomplete" : "Mark complete")

                        VStack(alignment: .leading, spacing: 6) {
                            Text(task.title)
                                .font(.title2.weight(.semibold))
                                .strikethrough(task.isCompleted)
                                .foregroundStyle(task.isCompleted ? AppTheme.completedText : .primary)

                            if !task.notes.isEmpty {
                                Text(task.notes)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Details") {
                    LabeledContent("List") {
                        Text(task.list?.name ?? "None")
                    }

                    LabeledContent("Due") {
                        if let due = task.dueDate {
                            Text(due.formatted(date: .abbreviated, time: .omitted))
                        } else {
                            Text("None")
                                .foregroundStyle(.secondary)
                        }
                    }

                    LabeledContent("Priority") {
                        Label(task.priority.displayName, systemImage: task.priority.systemImage)
                            .foregroundStyle(AppTheme.priorityColor(task.priority))
                    }

                    LabeledContent("Created") {
                        Text(task.createdAt.formatted(date: .abbreviated, time: .shortened))
                    }
                }

                Section {
                    Button(role: .destructive) {
                        modelContext.delete(task)
                        HapticFeedback.warning()
                        dismiss()
                    } label: {
                        Label("Delete Task", systemImage: "trash")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") { showingEdit = true }
                }
            }
            .sheet(isPresented: $showingEdit) {
                AddEditTaskView(task: task, defaultList: task.list, defaultDueDate: task.dueDate)
            }
        }
    }
}
