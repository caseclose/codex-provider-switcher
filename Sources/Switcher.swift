import AppKit
import Combine
import SwiftUI

// The status item and visible frame are both expressed in macOS screen coordinates.
enum ProviderPanelPosition {
    static func frame(anchor: NSRect, visibleFrame: NSRect, contentSize: NSSize) -> NSRect {
        let top = min(anchor.minY, visibleFrame.maxY)
        let width = min(contentSize.width, visibleFrame.width)
        let height = min(ceil(contentSize.height), max(0, top - visibleFrame.minY))
        let x = min(max(anchor.midX - width / 2, visibleFrame.minX), visibleFrame.maxX - width)
        return NSRect(x: x, y: top - height, width: width, height: height)
    }
}

private final class ProviderWindow: NSPanel {
    override var canBecomeKey: Bool { true }
}

@MainActor
final class Switcher: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private let status = NSStatusBar.system.statusItem(withLength: 27)
    private let panel = ProviderPanelState()
    private let settings = AppSettings()
    private let window = ProviderWindow(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel],
                                        backing: .buffered, defer: false)
    private lazy var host = NSHostingController(rootView: ProviderPanel(
        state: panel,
        settings: settings,
        confirm: { [weak self] in self?.confirmSelection() },
        cancel: { [weak self] in self?.closePanel() },
        quit: { NSApp.terminate(nil) }
    ))
    private var appearanceObservation: NSKeyValueObservation?
    private var panelObservation: AnyCancellable?
    private var settingsObservation: AnyCancellable?
    private var layoutScheduled = false
    private let launcher = DesktopLauncher(
        appURL: NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.openai.codex")
            ?? URL(fileURLWithPath: "/Applications/ChatGPT.app", isDirectory: true),
        bundleIdentifier: "com.openai.codex",
        providerCLI: Bundle.main.resourceURL!.appendingPathComponent("provider-codex")
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        status.button?.target = self
        status.button?.action = #selector(togglePanel(_:))
        status.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        appearanceObservation = status.button?.observe(\.effectiveAppearance) { [weak self] _, _ in
            Task { @MainActor in self?.refresh() }
        }
        window.level = .popUpMenu
        window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary, .transient]
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.hidesOnDeactivate = false
        host.sizingOptions = []
        window.contentViewController = host
        window.delegate = self
        window.appearance = settings.appearance.nativeAppearance
        panelObservation = panel.objectWillChange.sink { [weak self] in self?.schedulePanelLayout() }
        settingsObservation = settings.objectWillChange.sink { [weak self] in
            DispatchQueue.main.async { [weak self] in self?.applySettings() }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(screenParametersChanged),
                                               name: NSApplication.didChangeScreenParametersNotification, object: nil)

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
        let selection = panel.current ?? .openAI
        let label = L10n.text(panel.current == nil ? "defaultProvider" : "currentProvider", selection.title)
        let dark = status.button?.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if !panel.busy, let mark = ProviderArtwork.statusImage(for: selection.provider, dark: dark) {
            status.button?.image = mark
        } else {
            let fallback = NSImage(systemSymbolName: "arrow.left.arrow.right", accessibilityDescription: label)?
                .withSymbolConfiguration(.init(pointSize: 14, weight: .semibold))
            fallback?.isTemplate = true
            status.button?.image = fallback
        }
        status.button?.imagePosition = .imageOnly
        status.button?.setAccessibilityLabel(L10n.text("statusLabel", label))
        status.button?.toolTip = "Codex · \(label)"
    }

    @objc private func togglePanel(_ button: NSStatusBarButton) {
        if window.isVisible {
            closePanel()
            return
        }
        refresh()
        panel.prepareToOpen()
        guard layoutPanel() else { return }
        window.makeKeyAndOrderFront(nil)
    }

    func windowDidResignKey(_ notification: Notification) { closePanel() }

    @objc private func screenParametersChanged() { schedulePanelLayout() }

    private func applySettings() {
        window.appearance = settings.appearance.nativeAppearance
        refresh()
        schedulePanelLayout()
    }

    private func closePanel() {
        guard window.isVisible else { return }
        window.orderOut(nil)
        panel.cancelKeyEdit()
    }

    private func schedulePanelLayout() {
        guard window.isVisible, !layoutScheduled else { return }
        layoutScheduled = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.layoutScheduled = false
            if self.window.isVisible { _ = self.layoutPanel() }
        }
    }

    private func layoutPanel() -> Bool {
        guard let button = status.button, let statusWindow = button.window else { return false }
        let anchor = statusWindow.convertToScreen(button.convert(button.bounds, to: nil))
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(NSPoint(x: anchor.midX, y: anchor.midY)) })
                ?? statusWindow.screen else { return false }
        return layoutPanel(anchor: anchor, visibleFrame: screen.visibleFrame)
    }

    private func layoutPanel(anchor: NSRect, visibleFrame: NSRect) -> Bool {
        let size = host.sizeThatFits(in: NSSize(width: ProviderPanel.width, height: max(900, visibleFrame.height)))
        let frame = ProviderPanelPosition.frame(anchor: anchor, visibleFrame: visibleFrame, contentSize: size)
        guard frame.height > 0 else { return false }
        window.setFrame(frame, display: true)
        return true
    }

    private func confirmSelection() {
        guard panel.canConfirm else { return }
        let selection = panel.selected
        let restart = panel.keyChangedForCurrentSelection
        panel.error = nil
        panel.busy = true
        refresh()
        Task { @MainActor in
            defer {
                panel.busy = false
                refresh()
            }
            do {
                try await launcher.open(selection, restart: restart)
                panel.didLaunch()
                closePanel()
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
