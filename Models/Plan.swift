import Foundation

struct Plan: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var notes: String
    var durationMinutes: Int
    var startDate: Date
    var repeatRule: RepeatRule
    var completionHistory: Set<String>
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        durationMinutes: Int,
        startDate: Date,
        repeatRule: RepeatRule = .daily,
        completionHistory: Set<String> = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.durationMinutes = durationMinutes
        self.startDate = startDate
        self.repeatRule = repeatRule
        self.completionHistory = completionHistory
        self.createdAt = createdAt
    }

    func occurs(on date: Date, calendar: Calendar = .current) -> Bool {
        let normalizedStart = calendar.startOfDay(for: startDate)
        let target = calendar.startOfDay(for: date)

        guard target >= normalizedStart else {
            return false
        }

        switch repeatRule {
        case .none:
            return calendar.isDate(target, inSameDayAs: normalizedStart)
        case .daily:
            return true
        case .weekdays:
            guard let weekday = calendar.weekday(for: target) else {
                return false
            }
            return weekday != .saturday && weekday != .sunday
        case let .weekly(days):
            guard let weekday = calendar.weekday(for: target) else {
                return false
            }
            return days.contains(weekday)
        }
    }

    func isCompleted(on date: Date, calendar: Calendar = .current) -> Bool {
        completionHistory.contains(calendar.dayKey(for: date))
    }

    mutating func toggleCompletion(on date: Date, calendar: Calendar = .current) {
        let key = calendar.dayKey(for: date)
        if completionHistory.contains(key) {
            completionHistory.remove(key)
        } else {
            completionHistory.insert(key)
        }
    }
}
