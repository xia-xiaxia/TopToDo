import Foundation

enum Formatters {
    static let dayTitle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter
    }()

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let monthTitle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }()

    static func durationText(for minutes: Int) -> String {
        if minutes >= 60 {
            let hours = Double(minutes) / 60.0
            if hours.rounded() == hours {
                return "\(Int(hours)) 小时"
            }
            return String(format: "%.1f 小时", hours)
        }
        return "\(minutes) 分钟"
    }
}
