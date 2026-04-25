import AppKit
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) private var systemColorScheme

    @ObservedObject var store: PlanStore
    @State private var isPresentingAddSheet = false
    @State private var isPresentingExpandedCalendar = false
    @State private var isPresentingAppearancePopover = false
    @State private var selectedDate = Date.now
    @State private var displayedMonth = Calendar.autoupdatingCurrent.startOfMonth(for: .now)

    private let calendar = Calendar.autoupdatingCurrent

    private var activeColorScheme: ColorScheme {
        store.appearanceMode.colorScheme ?? systemColorScheme
    }

    private var theme: AppTheme {
        AppTheme.resolve(for: activeColorScheme)
    }

    private var plansForSelectedDay: [Plan] {
        store.plans(for: selectedDate)
    }

    private var mainWindowBackgroundImage: NSImage? {
        guard let path = store.mainWindowBackgroundImagePath else {
            return nil
        }
        return NSImage(contentsOfFile: path)
    }

    var body: some View {
        ZStack {
            windowBackground

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    datePickerCard
                    progressInsightsCard
                    todaySummaryCard
                    plansSection
                }
                .padding(20)
                .padding(.bottom, 24)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .sheet(isPresented: $isPresentingAddSheet) {
            PlanEditorSheet(store: store)
                .frame(width: 420, height: 520)
                .preferredColorScheme(store.appearanceMode.colorScheme)
        }
        .sheet(isPresented: $isPresentingExpandedCalendar) {
            expandedCalendarSheet
        }
        .onAppear {
            store.seedIfNeeded()
            displayedMonth = calendar.startOfMonth(for: selectedDate)
        }
        .onChange(of: selectedDate) { _, newValue in
            displayedMonth = calendar.startOfMonth(for: newValue)
        }
        .preferredColorScheme(store.appearanceMode.colorScheme)
    }

    @ViewBuilder
    private var windowBackground: some View {
        GeometryReader { proxy in
            ZStack {
                theme.windowGradient
                    .ignoresSafeArea()

                if let mainWindowBackgroundImage {
                    Image(nsImage: mainWindowBackgroundImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .ignoresSafeArea()

                    Rectangle()
                        .fill(theme.backgroundMaskColor.opacity(store.mainWindowBackgroundOpacity))
                        .ignoresSafeArea()
                } else {
                    theme.spotlight
                        .blendMode(activeColorScheme == .dark ? .screen : .normal)
                        .ignoresSafeArea()
                }

                theme.backgroundOverlay
                    .ignoresSafeArea()
            }
        }
        .allowsHitTesting(false)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("TopTodo")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                Text("把今天最重要的计划固定在顶部，打开就能立刻进入状态。")
                    .font(.callout)
                    .foregroundStyle(theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            HStack(spacing: 10) {
                Button {
                    isPresentingAppearancePopover.toggle()
                } label: {
                    Label("外观", systemImage: "paintbrush")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(theme.textSecondary)
                .popover(isPresented: $isPresentingAppearancePopover, arrowEdge: .top) {
                    AppearancePopover(store: store, theme: theme)
                }

                Button {
                    isPresentingAddSheet = true
                } label: {
                    Label("新计划", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(theme.accent)
            }
        }
        .padding(20)
        .background(cardBackground(cornerRadius: 26, fill: theme.surface.opacity(0.88)))
    }

    private var datePickerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("查看日期")
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Button("放大查看") {
                    isPresentingExpandedCalendar = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(theme.textSecondary)
            }

            calendarViewport(maxHeight: 430, minimumCellHeight: 48, headerFontSize: 24, dayFontSize: 18)
                .padding(.top, 8)
        }
        .padding(18)
        .background(cardBackground())
    }

    private var expandedCalendarSheet: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("放大日历")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary)
                    Text("这个视图会横向铺满，竖向不够时可以继续滚动。")
                        .foregroundStyle(theme.textSecondary)
                }
                Spacer()
                Button("今天") {
                    selectedDate = .now
                    displayedMonth = calendar.startOfMonth(for: .now)
                }
                .buttonStyle(.bordered)
                .tint(theme.textSecondary)
                Button("完成") {
                    isPresentingExpandedCalendar = false
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.accent)
            }

            calendarViewport(maxHeight: 520, minimumCellHeight: 72, headerFontSize: 34, dayFontSize: 28)
                .background(cardBackground(cornerRadius: 24, fill: theme.surface.opacity(0.88)))

            Spacer()
        }
        .padding(24)
        .frame(width: 760, height: 620)
        .background(windowBackground)
        .preferredColorScheme(store.appearanceMode.colorScheme)
    }

    private func calendarViewport(
        maxHeight: CGFloat,
        minimumCellHeight: CGFloat,
        headerFontSize: CGFloat,
        dayFontSize: CGFloat
    ) -> some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 320)
            let horizontalPadding: CGFloat = 16
            let interItemSpacing: CGFloat = 10
            let usableWidth = width - (horizontalPadding * 2)
            let cellWidth = max(usableWidth / 7.0 - interItemSpacing, minimumCellHeight)
            let rowCount = max(1, calendar.monthGrid(for: displayedMonth).count / 7)
            let contentHeight = 92 + CGFloat(rowCount) * (cellWidth + 10)

            ScrollView(.vertical, showsIndicators: contentHeight > maxHeight) {
                MonthCalendarView(
                    selectedDate: $selectedDate,
                    displayedMonth: $displayedMonth,
                    calendar: calendar,
                    headerFontSize: headerFontSize,
                    dayFontSize: dayFontSize,
                    cellHeight: cellWidth,
                    theme: theme
                )
                .frame(width: width, alignment: .topLeading)
                .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity)
        .frame(height: maxHeight)
    }

    private var todaySummaryCard: some View {
        let completedCount = plansForSelectedDay.filter { $0.isCompleted(on: selectedDate) }.count
        let pendingCount = max(0, plansForSelectedDay.count - completedCount)

        return HStack(spacing: 12) {
            summaryBlock(title: Formatters.dayTitle.string(from: selectedDate), value: "\(plansForSelectedDay.count) 个计划")
            summaryBlock(title: "未完成", value: "\(pendingCount) 个")
            summaryBlock(title: "已完成", value: "\(completedCount) 个")
        }
    }

    private var progressInsightsCard: some View {
        let weekly = store.weekProgress(containing: selectedDate)
        let monthly = store.monthProgress(containing: selectedDate)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("进展分析")
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Text("按“当天任务是否全部完成”统计")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }

            HStack(spacing: 12) {
                progressBlock(
                    title: "本周得分",
                    score: weekly.percentageText,
                    detail: "\(weekly.fractionText) 天完全完成"
                )
                progressBlock(
                    title: "本月得分",
                    score: monthly.percentageText,
                    detail: "\(monthly.fractionText) 天完全完成"
                )
            }
        }
        .padding(18)
        .background(cardBackground())
    }

    private func progressBlock(title: String, score: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
            Text(score)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimary)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(theme.elevatedSurface.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(theme.secondaryStroke, lineWidth: 1)
                )
        )
    }

    private func summaryBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
            Text(value)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(theme.surface.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(theme.secondaryStroke, lineWidth: 1)
                )
        )
    }

    private var plansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("计划列表")
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                if plansForSelectedDay.isEmpty {
                    Text("这一天没有安排")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                }
            }

            if plansForSelectedDay.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(plansForSelectedDay) { plan in
                        PlanRow(
                            plan: plan,
                            date: selectedDate,
                            theme: theme,
                            onToggleDone: { store.toggleCompletion(for: plan, on: selectedDate) },
                            onDelete: { store.removePlan(plan) }
                        )
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(18)
        .background(cardBackground())
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("还没有计划")
                .font(.title3.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
            Text("添加一个每天、工作日或指定星期重复的计划，让它固定显示在这里。")
                .foregroundStyle(theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Button("创建第一个计划") {
                isPresentingAddSheet = true
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.accent)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(theme.elevatedSurface.opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(theme.secondaryStroke, lineWidth: 1)
                )
        )
    }

    private func cardBackground(
        cornerRadius: CGFloat = 22,
        fill: Color? = nil
    ) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(fill ?? theme.surface.opacity(0.84))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(theme.stroke, lineWidth: 1)
            )
            .shadow(color: theme.shadow, radius: 28, y: 14)
    }
}

private struct AppearancePopover: View {
    @ObservedObject var store: PlanStore
    let theme: AppTheme

    private var opacityBinding: Binding<Double> {
        Binding(
            get: { store.mainWindowBackgroundOpacity },
            set: { store.setMainWindowBackgroundOpacity($0) }
        )
    }

    private var appearanceBinding: Binding<AppAppearanceMode> {
        Binding(
            get: { store.appearanceMode },
            set: { store.setAppearanceMode($0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("主窗口外观")
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                Text("可以切换浅色、深色，或者继续跟随系统。")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }

            Picker("主题模式", selection: appearanceBinding) {
                ForEach(AppAppearanceMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 10) {
                Button("选择背景") {
                    if let pickedURL = ImagePicker.pickBackgroundImage(
                        title: "选择主窗口背景图",
                        message: "支持 PNG、JPG、JPEG、HEIC、WEBP"
                    ) {
                        store.setMainWindowBackgroundImage(url: pickedURL)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.accent)

                Button("清除") {
                    store.setMainWindowBackgroundImage(url: nil)
                }
                .buttonStyle(.bordered)
                .disabled(store.mainWindowBackgroundImagePath == nil)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("背景遮罩")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(theme.textPrimary)
                    Spacer()
                    Text("\(Int((store.mainWindowBackgroundOpacity * 100).rounded()))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(theme.textSecondary)
                }

                Slider(value: opacityBinding, in: 0.12...0.9)
                    .tint(theme.accent)
            }

            if let path = store.mainWindowBackgroundImagePath {
                Text((path as NSString).lastPathComponent)
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(18)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(theme.elevatedSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(theme.stroke, lineWidth: 1)
                )
        )
    }
}

private struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var displayedMonth: Date

    let calendar: Calendar
    let headerFontSize: CGFloat
    let dayFontSize: CGFloat
    let cellHeight: CGFloat
    let theme: AppTheme

    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]

    private var monthDays: [Date] {
        calendar.monthGrid(for: displayedMonth)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 12) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: max(14, dayFontSize * 0.72), weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            Divider()
                .overlay(theme.secondaryStroke)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 12) {
                ForEach(monthDays, id: \.self) { day in
                    dayCell(for: day)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(theme.elevatedSurface.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(theme.secondaryStroke, lineWidth: 1)
                )
        )
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text(Formatters.monthTitle.string(from: displayedMonth))
                .font(.system(size: headerFontSize, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimary)

            Spacer()

            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: max(16, dayFontSize * 0.7), weight: .semibold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.textSecondary)

            Button {
                selectedDate = .now
                displayedMonth = calendar.startOfMonth(for: .now)
            } label: {
                Image(systemName: "circle.fill")
                    .font(.system(size: max(10, dayFontSize * 0.4)))
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.accent)

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: max(16, dayFontSize * 0.7), weight: .semibold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.textSecondary)
        }
    }

    private func dayCell(for day: Date) -> some View {
        let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
        let isCurrentMonth = calendar.isDate(day, equalTo: displayedMonth, toGranularity: .month)
        let cornerRadius = min(16, cellHeight * 0.28)

        return Button {
            selectedDate = day
            displayedMonth = calendar.startOfMonth(for: day)
        } label: {
            Text("\(calendar.component(.day, from: day))")
                .font(.system(size: dayFontSize, weight: .medium, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: cellHeight)
                .foregroundStyle(textColor(isSelected: isSelected, isCurrentMonth: isCurrentMonth))
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(isSelected ? theme.accent : theme.surface.opacity(0.65))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(isSelected ? theme.accent.opacity(0.7) : theme.secondaryStroke, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func moveMonth(by value: Int) {
        guard let nextMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) else {
            return
        }
        displayedMonth = calendar.startOfMonth(for: nextMonth)
    }

    private func textColor(isSelected: Bool, isCurrentMonth: Bool) -> Color {
        if isSelected {
            return theme.selectionText
        }
        return isCurrentMonth ? theme.textPrimary : theme.textTertiary
    }
}
