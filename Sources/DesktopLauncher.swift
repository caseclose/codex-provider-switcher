import AppKit

enum Provider: String {
    case openAI = "openai"
    case deepSeek = "deepseek"

    var title: String {
        switch self {
        case .openAI: "OpenAI"
        case .deepSeek: "DeepSeek Flash 1017"
        }
    }

    var opposite: Self { self == .openAI ? .deepSeek : .openAI }
}

@MainActor
final class DesktopLauncher {
    let appURL: URL
    let bundleIdentifier: String
    let deepSeekCLI: URL
    let preferences: UserDefaults
    private let workspace = NSWorkspace.shared

    init(appURL: URL, bundleIdentifier: String, deepSeekCLI: URL, preferences: UserDefaults = .standard) {
        self.appURL = appURL
        self.bundleIdentifier = bundleIdentifier
        self.deepSeekCLI = deepSeekCLI
        self.preferences = preferences
    }

    private var runningApps: [NSRunningApplication] {
        NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
            .filter { !$0.isTerminated && $0.bundleURL?.resolvingSymlinksInPath() == appURL.resolvingSymlinksInPath() }
    }

    var runningProvider: Provider? {
        guard let app = runningApps.first else { return nil }
        return provider(for: app)
    }

    private func provider(for app: NSRunningApplication) -> Provider {
        guard preferences.integer(forKey: "DeepSeekPID") == Int(app.processIdentifier),
              let launchedAt = app.launchDate,
              abs(preferences.double(forKey: "DeepSeekLaunchDate") - launchedAt.timeIntervalSince1970) < 0.1
        else { return .openAI }
        return .deepSeek
    }

    func open(_ provider: Provider) async throws {
        guard Bundle(url: appURL)?.bundleIdentifier == bundleIdentifier else {
            throw SwitchError.appMissing(appURL.path)
        }
        if provider == .deepSeek && !FileManager.default.isExecutableFile(atPath: deepSeekCLI.path) {
            throw SwitchError.launcherMissing
        }

        let apps = runningApps
        guard apps.count <= 1 else { throw SwitchError.multipleInstances }
        if let existing = apps.first {
            if self.provider(for: existing) == provider {
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
        if provider == .deepSeek {
            launch.environment = [
                "CODEX_CLI_PATH": deepSeekCLI.path,
                "CODEX_SWITCHER_DESKTOP_APP": appURL.path
            ]
        }
        let app = try await workspace.openApplication(at: appURL, configuration: launch)
        if provider == .deepSeek, let date = app.launchDate {
            preferences.set(Int(app.processIdentifier), forKey: "DeepSeekPID")
            preferences.set(date.timeIntervalSince1970, forKey: "DeepSeekLaunchDate")
        } else {
            preferences.removeObject(forKey: "DeepSeekPID")
            preferences.removeObject(forKey: "DeepSeekLaunchDate")
        }
    }
}

enum SwitchError: LocalizedError {
    case appMissing(String), launcherMissing, multipleInstances, quitRejected, quitTimedOut

    var errorDescription: String? {
        switch self {
        case .appMissing(let path): "找不到 ChatGPT Desktop。\n\(path)"
        case .launcherMissing: "找不到 DeepSeek 启动器。"
        case .multipleInstances: "有多个 ChatGPT 实例正在运行。请先退出多余的实例。"
        case .quitRejected: "ChatGPT 没有接受退出请求。请保存工作并退出 ChatGPT 后重试。"
        case .quitTimedOut: "ChatGPT 尚未退出。请检查它的退出提示，处理后再试。"
        }
    }
}
