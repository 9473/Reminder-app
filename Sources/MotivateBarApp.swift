import AppKit
import SwiftUI

@main
struct MotivateBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = ReminderStore()

    var body: some Scene {
        MenuBarExtra("MotivateBar", systemImage: "list.bullet.clipboard") {
            ContentView()
                .environmentObject(store)
                .frame(width: 360, height: 520)
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
