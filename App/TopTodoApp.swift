import AppKit
import SwiftUI

@main
struct TopTodoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = PlanStore()

    var body: some Scene {
        WindowGroup("TopTodo", id: "main") {
            ContentView(store: store)
                .frame(minWidth: 420, idealWidth: 500, maxWidth: 620, minHeight: 560, idealHeight: 700)
        }
        .defaultSize(width: 500, height: 700)
        .windowResizability(.contentSize)

        MenuBarExtra("TopTodo", systemImage: "checklist") {
            MenuBarPanel(store: store)
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
