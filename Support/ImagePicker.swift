import AppKit
import UniformTypeIdentifiers

enum ImagePicker {
    @MainActor
    static func pickBackgroundImage(title: String = "选择背景图", message: String = "支持 PNG、JPG、JPEG、HEIC、WEBP") -> URL? {
        let panel = NSOpenPanel()
        panel.title = title
        panel.message = message
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.resolvesAliases = true
        panel.allowedContentTypes = [
            .png,
            .jpeg,
            .heic,
            .webP
        ]

        return panel.runModal() == .OK ? panel.url : nil
    }
}
