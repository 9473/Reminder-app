import Foundation

enum ReminderKind: String, Codable, CaseIterable, Identifiable {
    case done
    case todo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .done:
            return "已经做过"
        case .todo:
            return "待办提醒"
        }
    }

    var symbol: String {
        switch self {
        case .done:
            return "●"
        case .todo:
            return "○"
        }
    }
}

struct ReminderItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var text: String
    var kind: ReminderKind
    var createdAt = Date()
}

struct AppState: Codable {
    var pinnedMessage = "今天也照计划推进，不自我放弃。"
    var items: [ReminderItem] = []
}
