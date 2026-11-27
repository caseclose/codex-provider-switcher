import AppKit
import SwiftUI

@MainActor
final class Switcher: NSObject, NSApplicationDelegate {
    private let status = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let popover = NSPopover()
    private let panel = ProviderPanelState()
    private var appearanceObservation: NSKeyValueObservation?
    private let launcher = DesktopLauncher(
        appURL: NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.openai.codex")
            ?? URL(fileURLWithPath: "/Applications/ChatGPT.app", isDirectory: true),
        bundleIdentifier: "com.openai.codex",
        deepSeekCLI: Bundle.main.resourceURL!.appendingPathComponent("deepseek-codex")
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        status.button?.target = self
        status.button?.action = #selector(togglePanel(_:))
        status.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        appearanceObservation = status.button?.observe(\.effectiveAppearance) { [weak self] _, _ in
            Task { @MainActor in self?.refresh() }
        }
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: ProviderPanel(
            state: panel,
            confirm: { [weak self] in self?.confirmSelection() },
            cancel: { [weak self] in self?.popover.close() },
            quit: { NSApp.terminate(nil) }
        ))

        let events = NSWorkspace.shared.notificationCenter
        for event in [NSWorkspace.didLaunchApplicationNotification, NSWorkspace.didTerminateApplicationNotification] {
            events.addObserver(self, selector: #selector(applicationsChanged(_:)), name: event, object: nil)
        }
        refresh()
    }

    @objc private func applicationsChanged(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              app.bundleIdentifier == launcher.bundleIdentifier else { return }
        refresh()
    }

    private func refresh() {
        panel.current = launcher.runningProvider
        let provider = panel.current ?? .openAI
        let label = panel.current == nil ? "默认 \(provider.title)" : "当前 \(provider.title)"
        let dark = status.button?.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if !panel.busy, let mark = ProviderArtwork.statusImage(for: provider, dark: dark) {
            status.button?.image = mark
        } else {
            let fallback = NSImage(systemSymbolName: "arrow.left.arrow.right", accessibilityDescription: label)?
                .withSymbolConfiguration(.init(pointSize: 14, weight: .semibold))
            fallback?.isTemplate = true
            status.button?.image = fallback
        }
        status.button?.imagePosition = .imageOnly
        status.button?.setAccessibilityLabel("Codex 提供商切换器，\(label)")
        status.button?.toolTip = "Codex · \(label)"
    }

    @objc private func togglePanel(_ button: NSStatusBarButton) {
        if popover.isShown {
            popover.close()
            return
        }
        refresh()
        panel.prepareToOpen()
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    private func confirmSelection() {
        guard panel.canConfirm else { return }
        let provider = panel.selected
        panel.error = nil
        panel.busy = true
        refresh()
        Task { @MainActor in
            defer {
                panel.busy = false
                refresh()
            }
            do {
                try await launcher.open(provider)
                popover.close()
            } catch {
                panel.error = error.localizedDescription
            }
        }
    }
}

@main
struct EntryPoint {
    @MainActor static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let switcher = Switcher()
        app.delegate = switcher
        app.run()
    }
}
