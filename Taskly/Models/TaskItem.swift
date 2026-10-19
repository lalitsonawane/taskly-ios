import Foundation
import SwiftData

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case none
    case low
    case medium
    case high

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "None"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    var systemImage: String {
        switch self {
        case .none: return "minus"
        case .low: return "arrow.down"
        case .medium: return "equal"
        case .high: return "arrow.up"
        }
    }
}

@Model
final class TaskItem: Identifiable {
    var id: UUID
    var title: String
    var notes: String
    var dueDate: Date?
    var priorityRaw: String
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?

    var list: TaskList?

    var priority: TaskPriority {
        get { TaskPriority(rawValue: priorityRaw) ?? .none }
        set { priorityRaw = newValue.rawValue }
    }

    init(
        title: String,
        notes: String = "",
        dueDate: Date? = nil,
        priority: TaskPriority = .none,
        isCompleted: Bool = false,
        list: TaskList? = nil,
        createdAt: Date = .now
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.priorityRaw = priority.rawValue
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = nil
        self.list = list
    }
}
