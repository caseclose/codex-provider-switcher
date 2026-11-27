import SwiftUI

@MainActor
final class ProviderPanelState: ObservableObject {
    @Published var current: ProviderSelection? {
        didSet { if current != oldValue { changedKey = nil } }
    }
    @Published private(set) var selected: ProviderSelection = .openAI
    @Published var busy = false
    @Published var error: String?
    @Published var keyDraft = ""
    @Published private(set) var hasKey = false
    @Published private(set) var editingKey = false
    @Published private var changedKey: ProviderSelection?

    var keyChangedForCurrentSelection: Bool { changedKey == selected && current == selected }
    var canConfirm: Bool {
        !busy && !editingKey && (selected.keychainService == nil || hasKey)
            && (selected != current || keyChangedForCurrentSelection)
    }

    func prepareToOpen() {
        guard !busy else { return }
        select(current ?? .openAI)
    }

    func select(_ provider: Provider) {
        let stored = UserDefaults.standard.string(forKey: "Region.\(provider.rawValue)")
        let region = stored.flatMap(ProviderRegion.init(rawValue:)) ?? .china
        select(ProviderSelection(provider: provider, region: region))
    }

    func selectRegion(_ region: ProviderRegion) {
        let provider = selected.provider
        UserDefaults.standard.set(region.rawValue, forKey: "Region.\(provider.rawValue)")
        select(ProviderSelection(provider: provider, region: region))
    }

    private func select(_ selection: ProviderSelection) {
        selected = selection
        error = nil
        cancelKeyEdit()
        hasKey = false
        guard let service = selection.keychainService else { return }
        do { hasKey = try ProviderKeychain.contains(service) }
        catch { self.error = error.localizedDescription }
    }

    func beginKeyEdit() {
        editingKey = true
        error = nil
    }

    func cancelKeyEdit() {
        keyDraft = ""
        editingKey = false
    }

    func saveKey() {
        guard let service = selected.keychainService else { return }
        let key = keyDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty, !key.contains(where: \.isWhitespace) else {
            error = "请输入完整的 API Key。"
            return
        }
        do {
            try ProviderKeychain.save(key, for: service)
            if current == selected { changedKey = selected }
            hasKey = true
            error = nil
            cancelKeyEdit()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func didLaunch() { changedKey = nil }
}

struct ProviderPanel: View {
    @ObservedObject var state: ProviderPanelState
    var confirm: () -> Void
    var cancel: () -> Void
    var quit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Codex 模型提供商")
                    .font(.system(size: 17, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button(action: quit) {
                    Image(systemName: "power")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 26, height: 26)
                        .background(Color.primary.opacity(0.055), in: RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
                .disabled(state.busy)
                .help("退出切换器")
                .accessibilityLabel("退出切换器")
            }

            VStack(spacing: 5) {
                ForEach(Provider.allCases, content: row)
            }
            .disabled(state.busy)

            if let setupURL = state.selected.setupURL {
                credentials(setupURL: setupURL)
                    .disabled(state.busy)
            }

            VStack(alignment: .leading, spacing: 11) {
                if let error = state.error {
                    Label(error, systemImage: "exclamationmark.circle")
                        .foregroundStyle(.red)
                        .font(.system(size: 11))
                        .fixedSize(horizontal: false, vertical: true)
                } else if state.current != nil {
                    Text("切换后会重新打开 ChatGPT，请先完成正在运行的任务。")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 8) {
                    Spacer()
                    Button("取消", action: cancel)
                        .keyboardShortcut(.cancelAction)
                    if state.busy {
                        ProgressView()
                            .controlSize(.small)
                            .accessibilityLabel("正在切换")
                    }
                    Button(state.current == nil ? "确认并打开" : "确认并重启", action: confirm)
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.defaultAction)
                        .disabled(!state.canConfirm)
                }
                .controlSize(.regular)
            }
        }
        .padding(16)
        .frame(width: 340)
        .onDisappear(perform: state.cancelKeyEdit)
    }

    private func row(_ provider: Provider) -> some View {
        ProviderOption(
            provider: provider,
            selected: state.selected.provider == provider,
            current: state.current?.provider == provider,
            select: { state.select(provider) }
        )
    }

    private func credentials(setupURL: URL) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Picker("账号地区", selection: Binding(get: { state.selected.region }, set: state.selectRegion)) {
                    ForEach(ProviderRegion.allCases) { region in
                        Text(region.title).tag(region)
                    }
                }
                .fixedSize()
                Spacer()
                if !state.editingKey {
                    Button(state.hasKey ? "更换 API Key" : "设置 API Key", action: state.beginKeyEdit)
                }
            }
            if state.editingKey {
                HStack {
                    SecureField("API Key", text: $state.keyDraft)
                        .onSubmit(state.saveKey)
                    Button("保存", action: state.saveKey)
                    Button("关闭", action: state.cancelKeyEdit)
                }
            }
            HStack {
                Text(state.hasKey ? "已存入 macOS 钥匙串" : "需要此套餐或平台的 API Key")
                    .foregroundStyle(.secondary)
                Spacer()
                Link("官方指南", destination: setupURL)
            }
            .font(.system(size: 11))
        }
    }
}

private struct ProviderOption: View {
    let provider: Provider
    let selected: Bool
    let current: Bool
    let select: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: select) {
            HStack(spacing: 10) {
                Group {
                    if let image = ProviderArtwork.logo(for: provider, dark: colorScheme == .dark) {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 19, height: 19)
                    } else {
                        Image(systemName: provider.symbol).font(.system(size: 17, weight: .semibold))
                    }
                }
                .frame(width: 30, height: 30)
                .background(Color.primary.opacity(0.055), in: RoundedRectangle(cornerRadius: 9))
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text(provider.title).font(.system(size: 13, weight: .semibold))
                    Text(provider.details)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if current {
                    Text("使用中")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(selected ? Color.accentColor : Color.secondary.opacity(0.48))
                    .accessibilityHidden(true)
            }
            .padding(7)
            .background(
                selected ? Color.accentColor.opacity(0.10) : Color.primary.opacity(0.035),
                in: RoundedRectangle(cornerRadius: 11)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .strokeBorder(selected ? Color.accentColor.opacity(0.56) : Color.primary.opacity(0.09))
            }
            .contentShape(RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}
