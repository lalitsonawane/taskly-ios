import SwiftUI
import UIKit

enum AppTheme {
    /// Soft teal accent - calm productivity, not purple.
    static let accent = Color(red: 0.07, green: 0.55, blue: 0.55)

    /// Soft neutral background for light-first UI.
    static let background = Color(red: 0.96, green: 0.97, blue: 0.97)

    static let secondaryBackground = Color(red: 0.92, green: 0.94, blue: 0.94)

    static let completedText = Color.secondary

    static let overdue = Color(red: 0.82, green: 0.28, blue: 0.28)

    static let priorityHigh = Color(red: 0.82, green: 0.28, blue: 0.28)
    static let priorityMedium = Color(red: 0.85, green: 0.55, blue: 0.15)
    static let priorityLow = Color(red: 0.35, green: 0.55, blue: 0.75)

    static func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .none: return .secondary
        case .low: return priorityLow
        case .medium: return priorityMedium
        case .high: return priorityHigh
        }
    }

    static let rowSpacing: CGFloat = 12
    static let horizontalPadding: CGFloat = 16
    static let cornerRadius: CGFloat = 12

    static let checkboxSpring = Animation.spring(response: 0.32, dampingFraction: 0.62)
}

enum HapticFeedback {
    static func taskCompleted() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
