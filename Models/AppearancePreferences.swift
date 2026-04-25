import Foundation

struct AppearancePreferences: Codable {
    var menuBarBackgroundImagePath: String?
    var mainWindowBackgroundImagePath: String?
    var mainWindowBackgroundOpacity: Double
    var appearanceMode: AppAppearanceMode

    init(
        menuBarBackgroundImagePath: String? = nil,
        mainWindowBackgroundImagePath: String? = nil,
        mainWindowBackgroundOpacity: Double = 0.32,
        appearanceMode: AppAppearanceMode = .system
    ) {
        self.menuBarBackgroundImagePath = menuBarBackgroundImagePath
        self.mainWindowBackgroundImagePath = mainWindowBackgroundImagePath
        self.mainWindowBackgroundOpacity = Self.clampOpacity(mainWindowBackgroundOpacity)
        self.appearanceMode = appearanceMode
    }

    static func clampOpacity(_ value: Double) -> Double {
        min(max(value, 0.12), 0.9)
    }
}
