import Foundation
import Combine

@MainActor
final class PlanStore: ObservableObject {
    @Published private(set) var plans: [Plan] = []
    @Published private(set) var appearance = AppearancePreferences()
    private let calendar = Calendar.autoupdatingCurrent
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let storageURL: URL
    private let appearanceURL: URL

    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        storageURL = Self.makeStorageURL()
        appearanceURL = Self.makeAppearanceURL()
        load()
        loadAppearance()
    }

    var menuBarBackgroundImagePath: String? {
        appearance.menuBarBackgroundImagePath
    }

    var mainWindowBackgroundImagePath: String? {
        appearance.mainWindowBackgroundImagePath
    }

    var mainWindowBackgroundOpacity: Double {
        appearance.mainWindowBackgroundOpacity
    }

    var appearanceMode: AppAppearanceMode {
        appearance.appearanceMode
    }

    var todaysPlans: [Plan] {
        plans(for: .now)
    }

    var pendingTodaysPlans: [Plan] {
        plans(for: .now).filter { !$0.isCompleted(on: .now, calendar: calendar) }
    }

    func dailyCompletionProgress(for date: Date = .now) -> Double {
        let dayPlans = plans(for: date)
        guard !dayPlans.isEmpty else {
            return 0
        }

        let completedCount = dayPlans.filter { $0.isCompleted(on: date, calendar: calendar) }.count
        return Double(completedCount) / Double(dayPlans.count)
    }

    func weekProgress(containing date: Date = .now) -> ProgressSnapshot {
        progressSnapshot(for: date, component: .weekOfYear)
    }

    func monthProgress(containing date: Date = .now) -> ProgressSnapshot {
        progressSnapshot(for: date, component: .month)
    }

    func plans(for date: Date) -> [Plan] {
        plans
            .filter { $0.occurs(on: date, calendar: calendar) }
            .sorted { lhs, rhs in
                let lhsCompleted = lhs.isCompleted(on: date, calendar: calendar)
                let rhsCompleted = rhs.isCompleted(on: date, calendar: calendar)

                if lhsCompleted != rhsCompleted {
                    return !lhsCompleted
                }
                if lhs.startDate != rhs.startDate {
                    return lhs.startDate < rhs.startDate
                }
                return lhs.createdAt < rhs.createdAt
            }
    }

    func addPlan(title: String, notes: String, durationMinutes: Int, startDate: Date, repeatRule: RepeatRule) {
        let normalizedDuration = max(5, durationMinutes)
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTitle.isEmpty else {
            return
        }

        plans.append(
            Plan(
                title: normalizedTitle,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                durationMinutes: normalizedDuration,
                startDate: calendar.startOfDay(for: startDate),
                repeatRule: repeatRule
            )
        )
        persist()
    }

    func removePlan(_ plan: Plan) {
        plans.removeAll { $0.id == plan.id }
        persist()
    }

    func setMenuBarBackgroundImage(url: URL?) {
        appearance.menuBarBackgroundImagePath = url?.path
        persistAppearance()
    }

    func setMainWindowBackgroundImage(url: URL?) {
        appearance.mainWindowBackgroundImagePath = url?.path
        persistAppearance()
    }

    func setMainWindowBackgroundOpacity(_ value: Double) {
        appearance.mainWindowBackgroundOpacity = AppearancePreferences.clampOpacity(value)
        persistAppearance()
    }

    func setAppearanceMode(_ mode: AppAppearanceMode) {
        appearance.appearanceMode = mode
        persistAppearance()
    }

    func toggleCompletion(for plan: Plan, on date: Date = .now) {
        guard let index = plans.firstIndex(where: { $0.id == plan.id }) else {
            return
        }
        plans[index].toggleCompletion(on: date, calendar: calendar)
        persist()
    }

    func seedIfNeeded() {
        guard plans.isEmpty else {
            return
        }

        plans = [
            Plan(title: "晨间计划", notes: "整理今天最重要的三件事", durationMinutes: 20, startDate: .now, repeatRule: .weekdays),
            Plan(title: "运动一下", notes: "哪怕只是拉伸和散步", durationMinutes: 30, startDate: .now, repeatRule: .daily),
            Plan(title: "周回顾", notes: "看看这周完成了什么", durationMinutes: 25, startDate: .now, repeatRule: .weekly(days: [.friday]))
        ]
        persist()
    }

    private func load() {
        guard let data = try? Data(contentsOf: storageURL) else {
            return
        }

        do {
            plans = try decoder.decode([Plan].self, from: data)
        } catch {
            plans = []
        }
    }

    private func persist() {
        do {
            let directory = storageURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true,
                attributes: nil
            )
            let data = try encoder.encode(plans)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            NSLog("Failed to persist plans: \(error.localizedDescription)")
        }
    }

    private static func makeStorageURL() -> URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return baseURL
            .appendingPathComponent("TopTodo", isDirectory: true)
            .appendingPathComponent("plans.json")
    }

    private static func makeAppearanceURL() -> URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return baseURL
            .appendingPathComponent("TopTodo", isDirectory: true)
            .appendingPathComponent("appearance.json")
    }

    private func progressSnapshot(for date: Date, component: Calendar.Component) -> ProgressSnapshot {
        guard let interval = calendar.dateInterval(of: component, for: date) else {
            return ProgressSnapshot(completedDays: 0, eligibleDays: 0)
        }

        let days = calendar.days(in: interval)
        var eligibleDays = 0
        var completedDays = 0

        for day in days {
            let dayPlans = plans(for: day)
            guard !dayPlans.isEmpty else {
                continue
            }

            eligibleDays += 1
            let allCompleted = dayPlans.allSatisfy { $0.isCompleted(on: day, calendar: calendar) }
            if allCompleted {
                completedDays += 1
            }
        }

        return ProgressSnapshot(completedDays: completedDays, eligibleDays: eligibleDays)
    }

    private func loadAppearance() {
        guard let data = try? Data(contentsOf: appearanceURL) else {
            return
        }

        do {
            appearance = try decoder.decode(AppearancePreferences.self, from: data)
        } catch {
            appearance = AppearancePreferences()
        }
    }

    private func persistAppearance() {
        do {
            let directory = appearanceURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true,
                attributes: nil
            )
            let data = try encoder.encode(appearance)
            try data.write(to: appearanceURL, options: .atomic)
        } catch {
            NSLog("Failed to persist appearance: \(error.localizedDescription)")
        }
    }
}
