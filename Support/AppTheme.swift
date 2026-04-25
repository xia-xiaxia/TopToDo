import AppKit
import SwiftUI

enum AppAppearanceMode: String, CaseIterable, Codable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            "跟随系统"
        case .light:
            "浅色"
        case .dark:
            "深色"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}

struct AppTheme {
    let accent: Color
    let accentSoft: Color
    let surface: Color
    let elevatedSurface: Color
    let stroke: Color
    let secondaryStroke: Color
    let shadow: Color
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color
    let windowGradient: LinearGradient
    let spotlight: RadialGradient
    let backgroundOverlay: LinearGradient
    let backgroundMaskColor: Color
    let selectionText: Color

    static func resolve(for scheme: ColorScheme) -> AppTheme {
        switch scheme {
        case .light:
            return AppTheme(
                accent: Color(nsColor: NSColor(calibratedRed: 0.09, green: 0.56, blue: 0.47, alpha: 1.0)),
                accentSoft: Color(nsColor: NSColor(calibratedRed: 0.45, green: 0.75, blue: 0.67, alpha: 1.0)),
                surface: Color(nsColor: NSColor(calibratedRed: 0.97, green: 0.98, blue: 0.99, alpha: 0.82)),
                elevatedSurface: Color(nsColor: NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.92)),
                stroke: Color.black.opacity(0.08),
                secondaryStroke: Color.black.opacity(0.05),
                shadow: Color.black.opacity(0.10),
                textPrimary: Color(nsColor: NSColor(calibratedRed: 0.10, green: 0.12, blue: 0.15, alpha: 1.0)),
                textSecondary: Color(nsColor: NSColor(calibratedRed: 0.30, green: 0.34, blue: 0.40, alpha: 1.0)),
                textTertiary: Color.black.opacity(0.40),
                windowGradient: LinearGradient(
                    colors: [
                        Color(nsColor: NSColor(calibratedRed: 0.95, green: 0.98, blue: 0.97, alpha: 1.0)),
                        Color(nsColor: NSColor(calibratedRed: 0.91, green: 0.95, blue: 0.98, alpha: 1.0)),
                        Color(nsColor: NSColor(calibratedRed: 0.98, green: 0.98, blue: 0.99, alpha: 1.0))
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                spotlight: RadialGradient(
                    colors: [
                        Color(nsColor: NSColor(calibratedRed: 0.55, green: 0.87, blue: 0.78, alpha: 0.28)),
                        Color(nsColor: NSColor(calibratedRed: 0.55, green: 0.87, blue: 0.78, alpha: 0.10)),
                        .clear
                    ],
                    center: .topTrailing,
                    startRadius: 20,
                    endRadius: 340
                ),
                backgroundOverlay: LinearGradient(
                    colors: [
                        Color.white.opacity(0.14),
                        Color.white.opacity(0.05),
                        Color.black.opacity(0.04)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                backgroundMaskColor: Color.white,
                selectionText: .white
            )
        case .dark:
            return AppTheme(
                accent: Color(nsColor: NSColor(calibratedRed: 0.36, green: 0.80, blue: 0.68, alpha: 1.0)),
                accentSoft: Color(nsColor: NSColor(calibratedRed: 0.23, green: 0.54, blue: 0.49, alpha: 1.0)),
                surface: Color(nsColor: NSColor(calibratedRed: 0.11, green: 0.13, blue: 0.15, alpha: 0.88)),
                elevatedSurface: Color(nsColor: NSColor(calibratedRed: 0.15, green: 0.17, blue: 0.20, alpha: 0.92)),
                stroke: Color.white.opacity(0.08),
                secondaryStroke: Color.white.opacity(0.05),
                shadow: Color.black.opacity(0.28),
                textPrimary: Color.white.opacity(0.96),
                textSecondary: Color.white.opacity(0.62),
                textTertiary: Color.white.opacity(0.42),
                windowGradient: LinearGradient(
                    colors: [
                        Color(nsColor: NSColor(calibratedRed: 0.05, green: 0.07, blue: 0.08, alpha: 1.0)),
                        Color(nsColor: NSColor(calibratedRed: 0.08, green: 0.10, blue: 0.12, alpha: 1.0)),
                        Color(nsColor: NSColor(calibratedRed: 0.04, green: 0.05, blue: 0.07, alpha: 1.0))
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                spotlight: RadialGradient(
                    colors: [
                        Color(nsColor: NSColor(calibratedRed: 0.36, green: 0.80, blue: 0.68, alpha: 0.22)),
                        Color(nsColor: NSColor(calibratedRed: 0.36, green: 0.80, blue: 0.68, alpha: 0.06)),
                        .clear
                    ],
                    center: .topTrailing,
                    startRadius: 40,
                    endRadius: 320
                ),
                backgroundOverlay: LinearGradient(
                    colors: [
                        Color.black.opacity(0.12),
                        Color.black.opacity(0.22),
                        Color.black.opacity(0.34)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                backgroundMaskColor: .black,
                selectionText: Color.black.opacity(0.82)
            )
        @unknown default:
            return resolve(for: .light)
        }
    }
}
