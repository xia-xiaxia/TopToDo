import Foundation

struct ProgressSnapshot {
    let completedDays: Int
    let eligibleDays: Int

    var score: Double {
        guard eligibleDays > 0 else {
            return 0
        }
        return Double(completedDays) / Double(eligibleDays)
    }

    var percentageText: String {
        "\(Int((score * 100).rounded()))%"
    }

    var fractionText: String {
        "\(completedDays)/\(eligibleDays)"
    }
}
