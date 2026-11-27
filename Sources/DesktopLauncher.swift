import AppKit

@MainActor
final class DesktopLauncher {
    let appURL: URL
    let bundleIdentifier: String
    let providerCLI: URL
    let preferences: UserDefaults
    private let workspace = NSWorkspace.shared

    init(appURL: URL, bundleIdentifier: String, providerCLI: URL, preferences: UserDefaults = .standard) {
        self.appURL = appURL
        self.bundleIdentifier = bundleIdentifier
        self.providerCLI = providerCLI
        self.preferences = preferences
    }

    private var runningApps: [NSRunningApplication] {
        NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
            .filter { !$0.isTerminated && $0.bundleURL?.resolvingSymlinksInPath() == appURL.resolvingSymlinksInPath() }
    }

    var runningProvider: ProviderSelection? {
        guard let app = runningApps.first else { return nil }
        return provider(for: app)
    }

    private func provider(for app: NSRunningApplication) -> ProviderSelection {
        guard let launchedAt = app.launchDate?.timeIntervalSince1970 else { return .openAI }
        let pid = Int(app.processIdentifier)
        if let launch = preferences.dictionary(forKey: "ProviderLaunch"),
           launch["pid"] as? Int == pid,
           let date = launch["date"] as? Double, abs(date - launchedAt) < 0.1,
           let provider = (launch["provider"] as? String).flatMap(Provider.init(rawValue:)),
           let region = (launch["region"] as? String).flatMap(ProviderRegion.init(rawValue:)) {
            return ProviderSelection(provider: provider, region: region)
        }
        if preferences.integer(forKey: "DeepSeekPID") == pid,
           abs(preferences.double(forKey: "DeepSeekLaunchDate") - launchedAt) < 0.1 {
            return ProviderSelection(provider: .deepSeek)
        }
        return .openAI
    }

    func open(_ selection: ProviderSelection, restart: Bool = false) async throws {
        guard Bundle(url: appURL)?.bundleIdentifier == bundleIdentifier else {
            throw SwitchError.appMissing(appURL.path)
        }
        let environment = try await launchEnvironment(for: selection)

        let apps = runningApps
        guard apps.count <= 1 else { throw SwitchError.multipleInstances }
        if let existing = apps.first {
            if provider(for: existing) == selection && !restart {
                existing.activate()
                return
            }
            guard existing.terminate() else { throw SwitchError.quitRejected }
            for _ in 0..<150 {
                if existing.isTerminated { break }
                try await Task.sleep(nanoseconds: 200_000_000)
            }
            guard existing.isTerminated else { throw SwitchError.quitTimedOut }
        }

        let launch = NSWorkspace.OpenConfiguration()
        launch.activates = true
        launch.addsToRecentItems = false
        if let environment { launch.environment = environment }
        let app = try await workspace.openApplication(at: appURL, configuration: launch)
        if environment != nil, let date = app.launchDate {
            preferences.set([
                "pid": Int(app.processIdentifier), "date": date.timeIntervalSince1970,
                "provider": selection.provider.rawValue, "region": selection.region.rawValue
            ], forKey: "ProviderLaunch")
        } else {
            preferences.removeObject(forKey: "ProviderLaunch")
        }
        preferences.removeObject(forKey: "DeepSeekPID")
        preferences.removeObject(forKey: "DeepSeekLaunchDate")
    }

    private func launchEnvironment(for selection: ProviderSelection) async throws -> [String: String]? {
        let provider = selection.provider
        guard let model = provider.model else { return nil }
        let catalog = providerCLI.deletingLastPathComponent().appendingPathComponent("\(model)-models.json")
        let files = FileManager.default
        guard files.isExecutableFile(atPath: providerCLI.path), files.isReadableFile(atPath: catalog.path) else {
            throw SwitchError.launcherMissing
        }
        let runtime = appURL.appendingPathComponent("Contents/Resources/codex-cli")
        let binaries = ["CodexCLI.app/Contents/MacOS/codex", "bin/codex"]
        guard binaries.contains(where: { files.isExecutableFile(atPath: runtime.appendingPathComponent($0).path) }) else {
            throw SwitchError.bundledCLIMissing
        }
        if provider.requiresBridge {
            let resources = runtime.deletingLastPathComponent()
            let nodePaths = ["node", "cua_node/bin/node"]
            let bridge = providerCLI.deletingLastPathComponent().appendingPathComponent("responses-bridge.mjs")
            guard nodePaths.contains(where: { files.isExecutableFile(atPath: resources.appendingPathComponent($0).path) }),
                  files.isReadableFile(atPath: bridge.path) else {
                throw SwitchError.bridgeMissing
            }
        }

        var environment = [
            "CODEX_CLI_PATH": providerCLI.path,
            "CODEX_SWITCHER_DESKTOP_APP": appURL.path,
            "CODEX_SWITCHER_PROVIDER": provider.rawValue,
            "CODEX_SWITCHER_MODEL": model
        ]
        if let baseURL = selection.baseURL, let service = selection.keychainService {
            guard try ProviderKeychain.contains(service) else {
                guard provider == .deepSeek else { throw SwitchError.keyMissing(selection.title) }
                guard try await acceptsLegacyDeepSeekConfig(environment) else { throw SwitchError.deepSeekSetupRequired }
                return environment
            }
            if provider == .deepSeek { environment["CODEX_SWITCHER_PROVIDER"] = "switcher_deepseek" }
            environment["CODEX_SWITCHER_BASE_URL"] = baseURL
            environment["CODEX_SWITCHER_KEYCHAIN_SERVICE"] = service
            environment["CODEX_SWITCHER_KEYCHAIN_ACCOUNT"] = ProviderKeychain.account
        }
        return environment
    }

    private func acceptsLegacyDeepSeekConfig(_ overrides: [String: String]) async throws -> Bool {
        let probe = Process()
        probe.executableURL = providerCLI
        probe.arguments = ["app-server", "--print-startup-config"]
        probe.environment = ProcessInfo.processInfo.environment.merging(overrides) { _, value in value }
        probe.standardInput = FileHandle.nullDevice
        probe.standardOutput = FileHandle.nullDevice
        probe.standardError = FileHandle.nullDevice
        return try await withCheckedThrowingContinuation { continuation in
            probe.terminationHandler = { process in
                continuation.resume(returning: process.terminationStatus == 0)
            }
            do { try probe.run() }
            catch { continuation.resume(throwing: error) }
        }
    }
}

enum SwitchError: LocalizedError {
    case appMissing(String), launcherMissing, bundledCLIMissing, bridgeMissing, keyMissing(String), deepSeekSetupRequired
    case multipleInstances, quitRejected, quitTimedOut

    var errorDescription: String? {
        switch self {
        case .appMissing(let path): L10n.text("desktopMissing", path)
        case .launcherMissing: L10n.text("launcherMissing")
        case .bundledCLIMissing: L10n.text("cliMissing")
        case .bridgeMissing: L10n.text("bridgeMissing")
        case .keyMissing(let title): L10n.text("missingKey", title)
        case .deepSeekSetupRequired: L10n.text("deepSeekSetupRequired")
        case .multipleInstances: L10n.text("multipleInstances")
        case .quitRejected: L10n.text("quitRejected")
        case .quitTimedOut: L10n.text("quitTimedOut")
        }
    }
}
