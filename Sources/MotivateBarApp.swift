import AppKit
import SwiftUI

@main
struct ReminderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private let store = ReminderStore()
    private let popover = NSPopover()
    private var statusItem: NSStatusItem!
    private var localMonitor: Any?
    private var globalMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let hostingController = NSHostingController(
            rootView: ContentView()
                .environmentObject(store)
        )
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 390, height: 560)

        popover.contentViewController = hostingController
        popover.contentSize = NSSize(width: 390, height: 560)
        popover.behavior = .applicationDefined
        popover.delegate = self

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "list.bullet.clipboard", accessibilityDescription: "Reminder")
            button.toolTip = "Reminder"
            button.target = self
            button.action = #selector(togglePopover(_:))
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            self?.handleEvent(event)
            return event
        }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            Task { @MainActor in
                self?.handleEvent(event)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }
    }

    @objc
    private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
            return
        }

        guard let button = statusItem.button else { return }
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    private func handleEvent(_ event: NSEvent) {
        guard popover.isShown else { return }
        guard !store.isEditing else { return }
        guard let popoverWindow = popover.contentViewController?.view.window else { return }
        let mouseLocation = NSEvent.mouseLocation

        if contains(mouseLocation, in: popoverWindow) || contains(mouseLocation, in: statusItem.button?.window) {
            return
        }

        popover.performClose(nil)
    }

    private func contains(_ screenPoint: NSPoint, in window: NSWindow?) -> Bool {
        guard let window else { return false }

        if window.frame.contains(screenPoint) {
            return true
        }

        if let childWindows = window.childWindows {
            for childWindow in childWindows where contains(screenPoint, in: childWindow) {
                return true
            }
        }

        return false
    }
}
