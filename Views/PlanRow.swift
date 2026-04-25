import SwiftUI

struct PlanRow: View {
    let plan: Plan
    let date: Date
    let theme: AppTheme
    let onToggleDone: () -> Void
    let onDelete: () -> Void

    private var isCompleted: Bool {
        plan.isCompleted(on: date)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggleDone) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isCompleted ? theme.accent : theme.textSecondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text(plan.title)
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                    .strikethrough(isCompleted, color: theme.textTertiary)

                if !plan.notes.isEmpty {
                    Text(plan.notes)
                        .font(.subheadline)
                        .foregroundStyle(theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 8) {
                    planTag(systemImage: "clock", text: Formatters.durationText(for: plan.durationMinutes))
                    planTag(systemImage: "repeat", text: plan.repeatRule.summary)
                    planTag(systemImage: "calendar", text: Formatters.shortDate.string(from: plan.startDate))
                }
            }

            Spacer(minLength: 0)

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(Color.red.opacity(0.9))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(theme.elevatedSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(theme.stroke, lineWidth: 1)
                )
        )
        .shadow(color: theme.shadow.opacity(0.45), radius: 18, y: 10)
    }

    private func planTag(systemImage: String, text: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.caption)
            .foregroundStyle(theme.textSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(theme.surface.opacity(0.9), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(theme.secondaryStroke, lineWidth: 1)
            )
    }
}
