import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Bindable var task: TaskItem
    var showListName: Bool = false
    var onToggleComplete: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.rowSpacing) {
            Button {
                withAnimation(AppTheme.checkboxSpring) {
                    task.isCompleted.toggle()
                    task.completedAt = task.isCompleted ? .now : nil
                    HapticFeedback.taskCompleted()
                    onToggleComplete?()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? AppTheme.accent : Color.secondary)
                    .symbolEffect(.bounce, value: task.isCompleted)
                    .accessibilityLabel(task.isCompleted ? "Mark incomplete" : "Mark complete")
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted, color: AppTheme.completedText)
                    .foregroundStyle(task.isCompleted ? AppTheme.completedText : .primary)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 8) {
                    if showListName, let listName = task.list?.name {
                        Label(listName, systemImage: "folder")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let dueDate = task.dueDate {
                        Label(dueDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(dueDateStyle(dueDate))
                    }

                    if task.priority != .none {
                        Label(task.priority.displayName, systemImage: task.priority.systemImage)
                            .font(.caption)
                            .foregroundStyle(AppTheme.priorityColor(task.priority))
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityValue(accessibilityValue)
    }

    private func dueDateStyle(_ date: Date) -> Color {
        if task.isCompleted { return .secondary }
        if date < Calendar.current.startOfDay(for: .now) {
            return AppTheme.overdue
        }
        return .secondary
    }

    private var accessibilityValue: String {
        var parts: [String] = []
        if task.isCompleted { parts.append("Completed") }
        if let due = task.dueDate {
            parts.append("Due \(due.formatted(date: .abbreviated, time: .omitted))")
        }
        if task.priority != .none {
            parts.append("\(task.priority.displayName) priority")
        }
        return parts.joined(separator: ", ")
    }
}
