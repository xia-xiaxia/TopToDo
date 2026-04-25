import SwiftUI

struct PlanEditorSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var store: PlanStore
    @State private var title = ""
    @State private var notes = ""
    @State private var durationMinutes = 30
    @State private var startDate = Date.now
    @State private var repeatPreset: RepeatPreset = .daily
    @State private var weeklySelection: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]

    private var theme: AppTheme {
        AppTheme.resolve(for: colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("创建计划")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimary)

            Form {
                TextField("计划名称", text: $title)

                TextField("备注（可选）", text: $notes, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)

                Stepper(value: $durationMinutes, in: 5...720, step: 5) {
                    LabeledContent("持续时间", value: Formatters.durationText(for: durationMinutes))
                }

                DatePicker("开始日期", selection: $startDate, displayedComponents: .date)

                Picker("重复", selection: $repeatPreset) {
                    ForEach(RepeatPreset.allCases) { preset in
                        Text(preset.title).tag(preset)
                    }
                }

                if repeatPreset == .weeklyCustom {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("每周重复日")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                            ForEach(Weekday.allCases.sorted()) { day in
                                Button {
                                    toggle(day)
                                } label: {
                                    Text(day.localizedLabel)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(weeklySelection.contains(day) ? theme.accent : theme.textTertiary.opacity(0.65))
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)

            Spacer()

            HStack {
                Button("取消") {
                    dismiss()
                }

                Spacer()

                Button("保存计划") {
                    store.addPlan(
                        title: title,
                        notes: notes,
                        durationMinutes: durationMinutes,
                        startDate: startDate,
                        repeatRule: makeRule()
                    )
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.accent)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !isRuleValid)
            }
        }
        .padding(20)
        .background(
            ZStack {
                theme.windowGradient
                theme.spotlight
                theme.backgroundOverlay
            }
        )
    }

    private var isRuleValid: Bool {
        repeatPreset != .weeklyCustom || !weeklySelection.isEmpty
    }

    private func makeRule() -> RepeatRule {
        switch repeatPreset {
        case .none:
            .none
        case .daily:
            .daily
        case .weekdays:
            .weekdays
        case .weeklyCustom:
            .weekly(days: weeklySelection)
        }
    }

    private func toggle(_ day: Weekday) {
        if weeklySelection.contains(day) {
            weeklySelection.remove(day)
        } else {
            weeklySelection.insert(day)
        }
    }
}

private enum RepeatPreset: String, CaseIterable, Identifiable {
    case none
    case daily
    case weekdays
    case weeklyCustom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none:
            "仅一次"
        case .daily:
            "每天"
        case .weekdays:
            "工作日"
        case .weeklyCustom:
            "自定义星期"
        }
    }
}
