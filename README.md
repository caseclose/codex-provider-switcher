<p align="center">
  <img src="docs/assets/app-icon.png" alt="" width="80" height="80">
</p>

<h1 align="center">Provider Switcher for Codex</h1>

<p align="center">Choose a provider from the macOS menu bar, then confirm to open a new local Codex Desktop session.</p>

<p align="center">
  <a href="https://github.com/caseclose/codex-provider-switcher/releases/latest">Download for macOS</a>
  · <a href="https://caseclose.github.io/codex-provider-switcher/">Project website</a>
  · <a href="#中文说明">中文说明</a>
</p>

<p align="center"><sub>macOS 14+ · Apple silicon and Intel · MIT</sub></p>

## Quick start

1. Install and open the official ChatGPT desktop app at least once. The switcher requires macOS 14 or later. The release contains a universal binary for Apple silicon and Intel.
2. Download `Codex-Provider-Switcher-macOS.zip` from [Releases](https://github.com/caseclose/codex-provider-switcher/releases/latest). Unzip it and move the app to Applications. The build is ad-hoc signed and has not been Apple-notarized. You can also [build it locally](#build).
3. Open the switcher. Click its menu bar icon, choose a provider, then confirm. If ChatGPT is open, switching quits and reopens it. Finish active work first and start a fresh local Codex session after switching.

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/previews/en-dark.png">
    <img src="docs/assets/previews/en-light.png" alt="Nine provider options with the DeepSeek API key setup visible." width="340">
  </picture>
</p>

## Settings

Open the gear in the menu bar panel to choose Simplified Chinese, Traditional Chinese, English, or Japanese, and System, Light, or Dark appearance. The default appearance follows macOS. The **About** section shows the installed version, checks GitHub for the latest stable release, and links to the issue form.

The panel opens directly below the menu bar. On smaller displays, the provider list scrolls while the header and confirmation controls remain in view.

The website also follows system appearance by default. Read it in [简体中文](https://caseclose.github.io/codex-provider-switcher/?lang=zh-Hans), [繁體中文](https://caseclose.github.io/codex-provider-switcher/?lang=zh-Hant), [English](https://caseclose.github.io/codex-provider-switcher/?lang=en), or [日本語](https://caseclose.github.io/codex-provider-switcher/?lang=ja).

## Providers

| Menu option | Default model | Access |
| --- | --- | --- |
| OpenAI | Desktop default | Your usual Codex sign-in and configuration |
| DeepSeek | `deepseek-flash` | [DeepSeek API](#set-up-deepseek-once) |
| ZCode / GLM Coding Plan | `glm-5.4` | GLM Coding Plan API key from BigModel or Z.ai |
| Kimi Coding Plan | `kimi-for-coding` | Kimi Code API key from the Kimi Code console |
| GLM API | `glm-5.3` | Pay-as-you-go API key from BigModel or Z.ai |
| Kimi API | `kimi-k3` | Pay-as-you-go API key from Moonshot Open Platform |
| Gemini API | `gemini-3.8-flash` | [Google AI Studio API key](https://aistudio.google.com/apikey) |
| Claude API | `claude-sonnet-5-5` | [Workspace-scoped Claude API key](https://platform.claude.com/settings/keys) |
| Grok API | `grok-4.7` | [xAI API key](https://console.x.ai/) |

### Set up Gemini, Claude, or Grok

Select the provider in the menu, save its API key, and confirm the switch. Start a fresh local Codex session after ChatGPT reopens.

Grok uses xAI's [Responses API](https://docs.x.ai/developers/grok-4-7). Gemini and Claude use a bridge bound to the Mac's loopback interface during the selected Codex launch. It forwards standard chat, image inputs, and function calls to the official [Gemini](https://aistudio.google.com/docs/openai) or [Claude](https://platform.claude.com/docs/en/cli-sdks-libraries/libraries/openai-sdk) Chat Completions endpoint. The bridge uses the Node runtime bundled with ChatGPT Desktop. OpenAI-hosted tools and Responses server-side conversation state require separate support.

### Set up GLM or Kimi

1. Create an API key for the option you want. For ZCode, use a key from the GLM Coding Plan associated with your account. For Kimi Coding Plan, create a key in the Kimi Code console.
2. In the switcher, select the provider and the region that issued your key. Click **设置 API Key** (Set API Key), paste it and save. Each provider and region has its own macOS Keychain item.
3. Confirm the switch and start a new local Codex session. If macOS asks whether `security` may access the Keychain item for this provider, allow the lookup to continue.

GLM and Kimi requests go directly to the official regional Responses endpoint. A preset applies to the current launch. OpenAI uses your normal desktop startup. To keep OpenAI as the default for normal launches, leave `model_provider` unset in `~/.codex/config.toml` or set it to `"openai"`. The switcher applies its presets through launch arguments and leaves the configuration file intact.

| Provider | Mainland China | International |
| --- | --- | --- |
| GLM Coding Plan / GLM API | `https://open.bigmodel.cn/api/v1` | `https://api.z.ai/api/v1` |
| Kimi Coding Plan | `https://api.kimi.com/coding/v1` | `https://api.kimi.ai/coding/v1` |
| Kimi API | `https://api.moonshot.cn/v1` | `https://api.moonshot.ai/v1` |

Official guides · [BigModel Coding Plan](https://docs.bigmodel.cn/cn/coding-plan/tool/codex) · [Z.ai Coding Plan](https://docs.z.ai/devpack/tool/codex) · [GLM-5.3 API](https://docs.bigmodel.cn/cn/guide/models/text/glm-5.3) · [Kimi Code](https://www.kimi.com/code/docs/third-party-tools/codex.html) · [Kimi API](https://www.kimi.ai/resources/codex-api)

## Set up DeepSeek once

1. Create an API key in the [DeepSeek developer platform](https://platform.deepseek.com/api_keys).
2. Select **DeepSeek** in the switcher, click **Set API Key**, and save the key to macOS Keychain.
3. Confirm the switch and start a new local Codex session.

If your Codex configuration already has a working `deepseek` provider, you can switch without adding a new key. Here is the legacy configuration for a keychain item named `codex-provider-deepseek`.

```toml
[model_providers.deepseek]
name = "DeepSeek"
base_url = "https://api.deepseek.com"
wire_api = "responses"

[model_providers.deepseek.auth]
command = "/usr/bin/security"
args = ["find-generic-password", "-s", "codex-provider-deepseek", "-w"]
timeout_ms = 10000
```

If macOS prompts for Keychain access when switching, approve the lookup for the key you just saved. DeepSeek requests go to its official API and are billed by DeepSeek. The app bundles a Codex model catalog for `deepseek-flash` and supplies it only to the DeepSeek launch. The switcher uses a desktop CLI-path override and the bundled Codex executable, so desktop updates may affect compatibility.

## Build

On macOS with Xcode Command Line Tools installed, run:

```bash
./scripts/build.sh
```

The build downloads provider artwork from the official sources and writes the signed app bundle under `dist/`. An optional first argument sets the output directory.

## 中文说明

从 macOS 菜单栏打开切换器，可选 **OpenAI**、**DeepSeek**、**ZCode / GLM Coding Plan**、**Kimi Coding Plan**、**GLM API** 或 **Kimi API**。切换后新建一个本地 Codex 会话。

首次使用第三方 API 或套餐时，点击「设置 API Key」并保存到 macOS 钥匙串。GLM 和 Kimi 还需要选择密钥所属地区。已有可用的 `deepseek` 配置时，可以直接切换。Gemini 与 Claude 通过本机桥接调用官方 API，Grok 直连官方 Responses API。

## License

MIT for the project code and original switcher artwork. The provider marks belong to their respective owners. See [third-party notices](THIRD_PARTY_NOTICES.md).
