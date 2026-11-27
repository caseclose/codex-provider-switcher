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
        let environment = try launchEnvironment(for: selection)

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

    private func launchEnvironment(for selection: ProviderSelection) throws -> [String: String]? {
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

        var environment = [
            "CODEX_CLI_PATH": providerCLI.path,
            "CODEX_SWITCHER_DESKTOP_APP": appURL.path,
            "CODEX_SWITCHER_PROVIDER": provider.rawValue,
            "CODEX_SWITCHER_MODEL": model
        ]
        if let baseURL = selection.baseURL, let service = selection.keychainService {
            guard try ProviderKeychain.contains(service) else { throw SwitchError.keyMissing(selection.title) }
            environment["CODEX_SWITCHER_BASE_URL"] = baseURL
            environment["CODEX_SWITCHER_KEYCHAIN_SERVICE"] = service
            environment["CODEX_SWITCHER_KEYCHAIN_ACCOUNT"] = ProviderKeychain.account
        }
        return environment
    }
}

enum SwitchError: LocalizedError {
    case appMissing(String), launcherMissing, bundledCLIMissing, keyMissing(String)
    case multipleInstances, quitRejected, quitTimedOut

    var errorDescription: String? {
        switch self {
        case .appMissing(let path): "找不到 ChatGPT Desktop。\n\(path)"
        case .launcherMissing: "找不到提供商启动器或模型目录。请重新安装切换器。"
        case .bundledCLIMissing: "找不到 ChatGPT 自带的 Codex CLI。"
        case .keyMissing(let title): "请先保存 \(title) 的 API Key。"
        case .multipleInstances: "有多个 ChatGPT 实例正在运行。请先退出多余的实例。"
        case .quitRejected: "ChatGPT 没有接受退出请求。请保存工作并退出 ChatGPT 后重试。"
        case .quitTimedOut: "ChatGPT 尚未退出。请检查它的退出提示，处理后再试。"
        }
    }
}
