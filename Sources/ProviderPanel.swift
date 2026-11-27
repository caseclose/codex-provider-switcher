import SwiftUI

extension Provider {
    var details: String {
        switch self {
        case .openAI: "GPT · 默认"
        case .deepSeek: "Flash 1017"
        }
    }
}

@MainActor
final class ProviderPanelState: ObservableObject {
    @Published var current: Provider?
    @Published var selected: Provider = .openAI
    @Published var busy = false
    @Published var error: String?

    var canConfirm: Bool { !busy && selected != current }

    func prepareToOpen() {
        guard !busy else { return }
        selected = current ?? .openAI
        error = nil
    }
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

            VStack(spacing: 7) {
                row(.openAI)
                row(.deepSeek)
            }
            .disabled(state.busy)

            VStack(alignment: .leading, spacing: 11) {
                if let error = state.error {
                    Label(error, systemImage: "exclamationmark.circle")
                        .foregroundStyle(.red)
                        .font(.system(size: 11))
                        .fixedSize(horizontal: false, vertical: true)
                } else if state.current != nil {
                    Text("切换会重新打开 ChatGPT。请先完成正在运行的任务。")
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
        .frame(width: 306)
    }

    private func row(_ provider: Provider) -> some View {
        ProviderOption(
            provider: provider,
            selected: state.selected == provider,
            current: state.current == provider,
            select: {
                state.selected = provider
                state.error = nil
            }
        )
    }
}

private struct ProviderOption: View {
    let provider: Provider
    let selected: Bool
    let current: Bool
    let select: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    private var name: String { provider == .openAI ? "OpenAI" : "DeepSeek" }

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
                        Image(systemName: "cpu").font(.system(size: 15, weight: .semibold))
                    }
                }
                .frame(width: 34, height: 34)
                .background(Color.primary.opacity(0.055), in: RoundedRectangle(cornerRadius: 9))
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text(name).font(.system(size: 13, weight: .semibold))
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
            .padding(9)
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
