import SwiftUI
import SwiftData

struct ListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskList.sortOrder) private var lists: [TaskList]

    @State private var showingAddList = false
    @State private var newListName = ""
    @State private var listToRename: TaskList?
    @State private var renameText = ""

    private var sortedLists: [TaskList] {
        lists.sorted { lhs, rhs in
            if lhs.isInbox != rhs.isInbox { return lhs.isInbox && !rhs.isInbox }
            if lhs.sortOrder != rhs.sortOrder { return lhs.sortOrder < rhs.sortOrder }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedLists) { list in
                    NavigationLink {
                        ListDetailView(list: list)
                    } label: {
                        HStack {
                            Image(systemName: list.isInbox ? "tray.fill" : "folder.fill")
                                .foregroundStyle(AppTheme.accent)
                                .frame(width: 28)
                            Text(list.name)
                                .font(.body)
                            Spacer()
                            Text("\(openTaskCount(for: list))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(list.name), \(openTaskCount(for: list)) open tasks")
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if !list.isInbox {
                            Button(role: .destructive) {
                                deleteList(list)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                renameText = list.name
                                listToRename = list
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            .tint(AppTheme.accent)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Lists")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        newListName = ""
                        showingAddList = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                    .accessibilityLabel("Add list")
                }
            }
            .alert("New List", isPresented: $showingAddList) {
                TextField("List name", text: $newListName)
                Button("Cancel", role: .cancel) {}
                Button("Create") {
                    createList()
                }
                .disabled(newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } message: {
                Text("Give your list a short name.")
            }
            .alert("Rename List", isPresented: Binding(
                get: { listToRename != nil },
                set: { if !$0 { listToRename = nil } }
            )) {
                TextField("List name", text: $renameText)
                Button("Cancel", role: .cancel) {
                    listToRename = nil
                }
                Button("Save") {
                    saveRename()
                }
                .disabled(renameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func openTaskCount(for list: TaskList) -> Int {
        list.tasks.filter { !$0.isCompleted }.count
    }

    private func createList() {
        let name = newListName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let nextOrder = (lists.map({ $0.sortOrder }).max() ?? 0) + 1
        let list = TaskList(name: name, isInbox: false, sortOrder: nextOrder)
        modelContext.insert(list)
        HapticFeedback.selection()
        newListName = ""
    }

    private func saveRename() {
        guard let list = listToRename else { return }
        let name = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        list.name = name
        listToRename = nil
        HapticFeedback.selection()
    }

    private func deleteList(_ list: TaskList) {
        guard !list.isInbox else { return }
        withAnimation {
            modelContext.delete(list)
            HapticFeedback.warning()
        }
    }
}
