import Foundation

extension Calendar {
    func weekday(for date: Date) -> Weekday? {
        Weekday(rawValue: component(.weekday, from: date))
    }

    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? startOfDay(for: date)
    }

    func monthGrid(for month: Date) -> [Date] {
        let monthStart = startOfMonth(for: month)
        guard
            let monthInterval = dateInterval(of: .month, for: monthStart),
            let firstWeekInterval = dateInterval(of: .weekOfMonth, for: monthInterval.start),
            let lastIncludedDate = date(byAdding: .day, value: -1, to: monthInterval.end),
            let lastWeekInterval = dateInterval(of: .weekOfMonth, for: lastIncludedDate)
        else {
            return []
        }

        var dates: [Date] = []
        var current = firstWeekInterval.start
        while current < lastWeekInterval.end {
            dates.append(current)
            guard let next = date(byAdding: .day, value: 1, to: current) else {
                break
            }
            current = next
        }
        return dates
    }

    func days(in interval: DateInterval) -> [Date] {
        var dates: [Date] = []
        var current = startOfDay(for: interval.start)

        while current < interval.end {
            dates.append(current)
            guard let next = date(byAdding: .day, value: 1, to: current) else {
                break
            }
            current = next
        }

        return dates
    }

    func dayKey(for date: Date) -> String {
        let components = dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d-%02d-%02d", year, month, day)
    }
}
