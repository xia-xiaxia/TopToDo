import SwiftUI

struct MenuBarPanel: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var store: PlanStore
    @Environment(\.openWindow) private var openWindow

    private var theme: AppTheme {
        AppTheme.resolve(for: colorScheme)
    }

    private var pendingPlans: [Plan] {
        store.pendingTodaysPlans
    }

    private var progressValue: Double {
        store.dailyCompletionProgress()
    }

    private var backgroundImage: NSImage? {
        guard let path = store.menuBarBackgroundImagePath else {
            return nil
        }
        return NSImage(contentsOfFile: path)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("今天的计划")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary)
                    Text(Formatters.dayTitle.string(from: .now))
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                }

                Spacer()

                Button {
                    openWindow(id: "main")
                } label: {
                    Text("打开")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }

            HStack(spacing: 8) {
                Button("背景") {
                    if let pickedURL = ImagePicker.pickBackgroundImage(
                        title: "选择小窗背景图",
                        message: "支持 PNG、JPG、JPEG、HEIC、WEBP"
                    ) {
                        store.setMenuBarBackgroundImage(url: pickedURL)
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                if store.menuBarBackgroundImagePath != nil {
                    Button("清除") {
                        store.setMenuBarBackgroundImage(url: nil)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }

            if pendingPlans.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text(store.todaysPlans.isEmpty ? "今天还没有计划。" : "今天的计划已经全部完成。")
                        .foregroundStyle(theme.textSecondary)
                    Text(store.todaysPlans.isEmpty ? "先去主窗口加一个计划吧。" : "右下角的进度环已经到 100%。")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                }
                .frame(maxWidth: .infinity, minHeight: 122, alignment: .topLeading)
            } else {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(pendingPlans) { plan in
                            Button {
                                store.toggleCompletion(for: plan)
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "circle")
                                        .font(.system(size: 17))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(plan.title)
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundStyle(theme.textPrimary)
                                            .lineLimit(1)
                                        Text("\(Formatters.durationText(for: plan.durationMinutes)) · \(plan.repeatRule.summary)")
                                            .font(.system(size: 11, weight: .medium, design: .rounded))
                                            .foregroundStyle(theme.textSecondary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 2)
                                .padding(.vertical, 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(height: 132)
            }

            Divider()

            HStack {
                Button("主窗口") {
                    openWindow(id: "main")
                    NSApp.activate(ignoringOtherApps: true)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Spacer()

                DailyProgressRing(progress: progressValue, size: 38, theme: theme)
                    .frame(maxWidth: .infinity, alignment: .center)

                Button("退出") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(12)
        .frame(width: 316, height: 286, alignment: .top)
        .background(backgroundLayer)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(theme.stroke, lineWidth: 1)
        )
        .preferredColorScheme(store.appearanceMode.colorScheme)
    }

    @ViewBuilder
    private var backgroundLayer: some View {
        if let backgroundImage {
            ZStack {
                Image(nsImage: backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(theme.surface.opacity(0.72))
            }
        } else {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(theme.elevatedSurface.opacity(0.96))
        }
    }
}

private struct DailyProgressRing: View {
    let progress: Double
    let size: CGFloat
    let theme: AppTheme

    var body: some View {
        ZStack {
            Circle()
                .stroke(theme.accent.opacity(0.16), lineWidth: 6)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [theme.accentSoft.opacity(0.85), theme.accent],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text("\(Int((progress * 100).rounded()))%")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(theme.accent)
        }
        .frame(width: size, height: size)
        .help("今天已完成 \(Int((progress * 100).rounded()))%")
    }
}
