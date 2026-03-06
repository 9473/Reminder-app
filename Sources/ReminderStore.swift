import Foundation

@MainActor
final class ReminderStore: ObservableObject {
    @Published var state: AppState
    @Published private(set) var isEditing = false

    private let saveURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = supportDirectory.appendingPathComponent("Reminder", isDirectory: true)
        self.saveURL = appDirectory.appendingPathComponent("state.json")

        do {
            try FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        } catch {
            NSLog("Failed to create app support directory: \(error.localizedDescription)")
        }

        if
            let data = try? Data(contentsOf: saveURL),
            let decoded = try? decoder.decode(AppState.self, from: data)
        {
            self.state = decoded
        } else {
            self.state = AppState()
        }

        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func updatePinnedMessage(_ message: String) {
        state.pinnedMessage = message
        save()
    }

    func addItem(text: String, kind: ReminderKind) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        state.items.insert(ReminderItem(text: trimmed, kind: kind), at: 0)
        save()
    }

    func removeItems(at offsets: IndexSet) {
        state.items.remove(atOffsets: offsets)
        save()
    }

    func toggleKind(for item: ReminderItem) {
        guard let index = state.items.firstIndex(of: item) else { return }
        state.items[index].kind = state.items[index].kind == .todo ? .done : .todo
        save()
    }

    func setEditing(_ editing: Bool) {
        isEditing = editing
    }

    private func save() {
        do {
            let data = try encoder.encode(state)
            try data.write(to: saveURL, options: .atomic)
        } catch {
            NSLog("Failed to save state: \(error.localizedDescription)")
        }
    }
}
