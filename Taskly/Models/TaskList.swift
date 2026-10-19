import Foundation
import SwiftData

@Model
final class TaskList: Identifiable {
    var id: UUID
    var name: String
    var createdAt: Date
    var isInbox: Bool
    var sortOrder: Int

    @Relationship(deleteRule: .cascade)
    var tasks: [TaskItem]

    init(
        name: String,
        isInbox: Bool = false,
        sortOrder: Int = 0,
        createdAt: Date = .now
    ) {
        self.id = UUID()
        self.name = name
        self.isInbox = isInbox
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.tasks = []
    }
}
