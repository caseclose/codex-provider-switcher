import AppKit
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case system, simplified = "zh-Hans", traditional = "zh-Hant", english = "en", japanese = "ja"

    var id: Self { self }

    var title: String {
        switch self {
        case .system: L10n.text("system")
        case .simplified: "简体中文"
        case .traditional: "繁體中文"
        case .english: "English"
        case .japanese: "日本語"
        }
    }

    var resolved: Self {
        guard self == .system else { return self }
        for tag in Locale.preferredLanguages.map({ $0.lowercased() }) {
            let language = tag.split(separator: "-")
            switch language.first {
            case "zh":
                if language.contains("hans") { return .simplified }
                return language.contains(where: { ["hant", "tw", "hk", "mo"].contains($0) }) ? .traditional : .simplified
            case "en": return .english
            case "ja": return .japanese
            default: continue
            }
        }
        return .english
    }
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: Self { self }
    var title: String { L10n.text(rawValue) }

    var nativeAppearance: NSAppearance? {
        switch self {
        case .system: nil
        case .light: NSAppearance(named: .aqua)
        case .dark: NSAppearance(named: .darkAqua)
        }
    }
}

enum L10n {
    static let languagePreference = "AppLanguage"
    static let appearancePreference = "AppAppearance"

    static var language: AppLanguage {
        UserDefaults.standard.string(forKey: languagePreference)
            .flatMap(AppLanguage.init(rawValue:)) ?? .system
    }

    static func text(_ key: String, _ arguments: CVarArg...) -> String {
        let selected = language.resolved.rawValue
        let folder = Bundle.main.url(forResource: selected, withExtension: "lproj")
        let bundle = folder.flatMap(Bundle.init(url:)) ?? Bundle.main
        let value = bundle.localizedString(forKey: key, value: nil, table: nil)
        return arguments.isEmpty ? value : String(format: value, arguments: arguments)
    }
}

@MainActor
final class AppSettings: ObservableObject {
    @Published var language = L10n.language {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: L10n.languagePreference) }
    }
    @Published var appearance = UserDefaults.standard.string(forKey: L10n.appearancePreference)
        .flatMap(AppAppearance.init(rawValue:)) ?? .system {
        didSet { UserDefaults.standard.set(appearance.rawValue, forKey: L10n.appearancePreference) }
    }
    @Published private(set) var update: UpdateStatus = .idle

    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    static let issueURL = URL(string: "https://github.com/caseclose/codex-provider-switcher/issues/new")!
    private static let releaseURL = URL(string: "https://github.com/caseclose/codex-provider-switcher/releases/latest")!
    private static let releaseTagPath = "/caseclose/codex-provider-switcher/releases/tag/"

    enum UpdateStatus {
        case idle, checking, current, available(String), failed
    }

    static func releaseURL(for tag: String) -> URL? {
        URL(string: "https://github.com\(releaseTagPath)\(tag)")
    }

    static func versionParts(_ value: String) -> [Int]? {
        let trimmed = value.hasPrefix("v") ? value.dropFirst() : value[...]
        let parts = trimmed.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3 else { return nil }
        let numbers = parts.compactMap { Int($0) }
        return numbers.count == parts.count && numbers.allSatisfy { $0 >= 0 } ? numbers : nil
    }

    func checkForUpdates() async {
        if case .checking = update { return }
        update = .checking
        do {
            var request = URLRequest(url: Self.releaseURL, cachePolicy: .reloadIgnoringLocalCacheData,
                                     timeoutInterval: 12)
            request.httpMethod = "HEAD"
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode),
                  let destination = response.url, destination.scheme == "https", destination.host == "github.com",
                  destination.path == Self.releaseTagPath + destination.lastPathComponent,
                  let latest = Self.versionParts(destination.lastPathComponent),
                  let installed = Self.versionParts(Self.version)
            else {
                update = .failed
                return
            }
            update = installed.lexicographicallyPrecedes(latest)
                ? .available("v" + latest.map(String.init).joined(separator: ".")) : .current
        } catch {
            update = .failed
        }
    }
}

struct SettingsPanel: View {
    @ObservedObject var settings: AppSettings
    var back: () -> Void
    var quit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Button(action: back) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.borderless)
                .keyboardShortcut(.cancelAction)
                .help(L10n.text("back"))
                .accessibilityLabel(L10n.text("back"))
                Text(L10n.text("settings"))
                    .font(.system(size: 17, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }

            ViewThatFits(in: .vertical) {
                sections.fixedSize(horizontal: false, vertical: true)
                ScrollView { sections }
                    .scrollBounceBehavior(.basedOnSize)
            }
        }
    }

    private var sections: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(spacing: 10) {
                Picker(L10n.text("language"), selection: $settings.language) {
                    ForEach(AppLanguage.allCases) { choice in Text(choice.title).tag(choice) }
                }
                Picker(L10n.text("appearance"), selection: $settings.appearance) {
                    ForEach(AppAppearance.allCases) { choice in Text(choice.title).tag(choice) }
                }
            }
            .padding(12)
            .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 11))

            VStack(alignment: .leading, spacing: 9) {
                Text(L10n.text("about"))
                    .font(.system(size: 13, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)
                Text(L10n.text("version", AppSettings.version))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                HStack {
                    Button(L10n.text("checkUpdates")) { Task { await settings.checkForUpdates() } }
                        .disabled(checking)
                    if checking { ProgressView().controlSize(.small) }
                    Spacer()
                }
                updateMessage
                Divider()
                HStack {
                    Link(L10n.text("reportIssue"), destination: AppSettings.issueURL)
                    Spacer()
                    Button(L10n.text("quit"), action: quit).buttonStyle(.borderless)
                }
            }
            .padding(12)
            .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 11))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var checking: Bool {
        if case .checking = settings.update { return true }
        return false
    }

    @ViewBuilder private var updateMessage: some View {
        switch settings.update {
        case .idle, .checking: EmptyView()
        case .current:
            Text(L10n.text("upToDate")).font(.system(size: 11)).foregroundStyle(.secondary)
        case .available(let tag):
            if let url = AppSettings.releaseURL(for: tag) {
                Link(L10n.text("updateAvailable", tag), destination: url).font(.system(size: 11))
            }
        case .failed:
            Text(L10n.text("updateFailed")).font(.system(size: 11)).foregroundStyle(.secondary)
        }
    }
}
