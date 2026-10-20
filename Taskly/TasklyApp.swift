import SwiftUI
import SwiftData

@main
struct TasklyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TaskList.self,
            TaskItem.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .tint(AppTheme.accent)
        }
        .modelContainer(sharedModelContainer)
    }
}
