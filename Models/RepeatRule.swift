import Foundation

enum RepeatRule: Codable, Equatable {
    case none
    case daily
    case weekdays
    case weekly(days: Set<Weekday>)

    var title: String {
        switch self {
        case .none:
            return "仅一次"
        case .daily:
            return "每天"
        case .weekdays:
            return "工作日"
        case let .weekly(days):
            if days.isEmpty {
                return "每周"
            }
            return days.sorted().map(\.localizedLabel).joined(separator: "、")
        }
    }

    var summary: String {
        switch self {
        case .none:
            return "不重复"
        case .daily:
            return "每天"
        case .weekdays:
            return "每个工作日"
        case let .weekly(days):
            let labels = days.sorted().map(\.shortLabel).joined(separator: " ")
            return labels.isEmpty ? "每周" : "每周 \(labels)"
        }
    }
}
