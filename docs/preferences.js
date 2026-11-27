const translations = {
  "zh-Hans": {
    navigation: "项目导航", setupLink: "使用方法", language: "语言", theme: "主题",
    system: "跟随系统", light: "浅色", dark: "深色",
    platform: "macOS 菜单栏工具", headingFirst: "从菜单栏切换", headingSecond: "Codex 提供商",
    lead: "在 Codex Desktop 使用 OpenAI、DeepSeek、GLM、Kimi、Gemini、Claude 或 Grok。菜单支持保存 API Key 和切换编程套餐。",
    download: "下载 macOS 版", release: "查看 Release", compat: "macOS 14+ · Apple 芯片与 Intel · MIT",
    previewAlt: "切换面板列出九个选项，已选择 DeepSeek 并显示 API Key 设置。",
    previewCaption: "macOS 切换面板", providers: "支持的提供商",
    openAI: "沿用 Codex Desktop 的常规启动配置。",
    deepSeek: "DeepSeek Flash 1017，可在菜单中保存 API Key。",
    glmCoding: "GLM-5.4，使用智谱 BigModel 或 Z.ai 的套餐额度。",
    kimiCoding: "kimi-for-coding，使用 Kimi Code 的套餐额度。",
    glmAPI: "GLM-5.3，使用智谱开放平台按量计费。",
    kimiAPI: "Kimi K3，使用月之暗面开放平台按量计费。",
    geminiAPI: "Gemini 3.8 Flash，使用 Google AI Studio 的 API Key。",
    claudeAPI: "Claude Sonnet 5.5，使用 Claude 工作区的 API Key。",
    grokAPI: "Grok 4.7，直连 xAI Responses API。",
    setupTitle: "安装后怎么用", openTitle: "打开切换器",
    openBody: "先安装官方 ChatGPT Desktop，再把切换器移到「应用程序」，从菜单栏打开。",
    chooseTitle: "选择提供商", chooseBody: "在菜单里把 API Key 存入 macOS 钥匙串。GLM 和 Kimi 还需要选择账号地区。",
    confirmTitle: "确认并新建会话", confirmBody: "结束正在运行的任务后再确认。切换器会重新打开 ChatGPT，随后可以新建本地 Codex 会话。",
    glmGuide: "GLM 和 Kimi 配置", deepSeekGuide: "DeepSeek 配置",
    otherGuide: "Gemini、Claude 和 Grok 配置",
    footer: "独立开源工具。提供商图标归各品牌所有。", license: "MIT 许可证"
  },
  "zh-Hant": {
    navigation: "專案導覽", setupLink: "使用方式", language: "語言", theme: "外觀",
    system: "跟隨系統", light: "淺色", dark: "深色",
    platform: "macOS 選單列工具", headingFirst: "從選單列切換", headingSecond: "Codex 供應商",
    lead: "在 Codex Desktop 使用 OpenAI、DeepSeek、GLM、Kimi、Gemini、Claude 或 Grok。選單支援儲存 API 金鑰和切換程式設計方案。",
    download: "下載 macOS 版", release: "查看版本發行", compat: "macOS 14+ · Apple 晶片與 Intel · MIT",
    previewAlt: "切換面板列出九個選項，已選擇 DeepSeek 並顯示 API 金鑰設定。",
    previewCaption: "macOS 切換面板", providers: "支援的供應商",
    openAI: "沿用 Codex Desktop 的一般啟動設定。",
    deepSeek: "DeepSeek Flash 1017，可在選單中儲存 API 金鑰。",
    glmCoding: "GLM-5.4，使用智譜 BigModel 或 Z.ai 的方案額度。",
    kimiCoding: "kimi-for-coding，使用 Kimi Code 的方案額度。",
    glmAPI: "GLM-5.3，透過智譜開放平台按量計費。",
    kimiAPI: "Kimi K3，透過月之暗面開放平台按量計費。",
    geminiAPI: "Gemini 3.8 Flash，使用 Google AI Studio 的 API 金鑰。",
    claudeAPI: "Claude Sonnet 5.5，使用 Claude 工作區的 API 金鑰。",
    grokAPI: "Grok 4.7，直接連線至 xAI Responses API。",
    setupTitle: "安裝後如何使用", openTitle: "打開切換器",
    openBody: "先安裝官方 ChatGPT Desktop，再將切換器移到「應用程式」，從選單列打開。",
    chooseTitle: "選擇供應商", chooseBody: "從選單將 API 金鑰存入 macOS 鑰匙圈。GLM 和 Kimi 還需要選擇帳號地區。",
    confirmTitle: "確認並開啟新對話", confirmBody: "先完成執行中的工作再確認。切換器會重新開啟 ChatGPT，接著就能開啟新的本機 Codex 對話。",
    glmGuide: "GLM 與 Kimi 設定", deepSeekGuide: "DeepSeek 設定",
    otherGuide: "Gemini、Claude 與 Grok 設定",
    footer: "獨立開源工具。供應商圖示歸各品牌所有。", license: "MIT 授權條款"
  },
  en: {
    navigation: "Project navigation", setupLink: "Setup", language: "Language", theme: "Appearance",
    system: "System", light: "Light", dark: "Dark",
    platform: "macOS menu bar utility", headingFirst: "Switch Codex", headingSecond: "providers",
    lead: "Use OpenAI, DeepSeek, GLM, Kimi, Gemini, Claude, or Grok in Codex Desktop. Save API keys and switch coding plans in the menu.",
    download: "Download for macOS", release: "View release", compat: "macOS 14+ · Apple silicon and Intel · MIT",
    previewAlt: "The switcher lists nine options, with DeepSeek selected and its API key setup visible.",
    previewCaption: "macOS switcher preview", providers: "Supported providers",
    openAI: "Uses your regular Codex Desktop startup settings.",
    deepSeek: "DeepSeek Flash 1017 with API key setup in the menu.",
    glmCoding: "GLM-5.4 with your BigModel or Z.ai coding plan quota.",
    kimiCoding: "kimi-for-coding with your Kimi Code plan quota.",
    glmAPI: "GLM-5.3 with usage-based billing through BigModel or Z.ai.",
    kimiAPI: "Kimi K3 with usage-based billing through Moonshot Open Platform.",
    geminiAPI: "Gemini 3.8 Flash with a Google AI Studio API key.",
    claudeAPI: "Claude Sonnet 5.5 with a workspace-scoped Claude API key.",
    grokAPI: "Grok 4.7 through the xAI Responses API.",
    setupTitle: "Get started", openTitle: "Open the switcher",
    openBody: "Install the official ChatGPT Desktop app first. Move the switcher to Applications, then open it from the menu bar.",
    chooseTitle: "Choose a provider", chooseBody: "Save the API key from the menu to macOS Keychain. For GLM and Kimi, choose the region that issued your key.",
    confirmTitle: "Confirm and start a new session", confirmBody: "Finish any active tasks before confirming. The switcher reopens ChatGPT so you can start a fresh local Codex session.",
    glmGuide: "Set up GLM and Kimi", deepSeekGuide: "Set up DeepSeek",
    otherGuide: "Set up Gemini, Claude, and Grok",
    footer: "Independent open-source utility. Provider marks belong to their respective owners.", license: "MIT License"
  },
  ja: {
    navigation: "プロジェクトのナビゲーション", setupLink: "使い方", language: "言語", theme: "外観",
    system: "システムに合わせる", light: "ライト", dark: "ダーク",
    platform: "macOS メニューバーアプリ", headingFirst: "メニューバーから", headingSecond: "Codex の接続先を切り替え",
    lead: "Codex Desktop で OpenAI、DeepSeek、GLM、Kimi、Gemini、Claude、Grok を選べます。メニューから API キーやコーディングプランを設定できます。",
    download: "macOS 版をダウンロード", release: "リリースを見る", compat: "macOS 14 以降 · Apple シリコンと Intel · MIT",
    previewAlt: "切り替えパネルに 9 つの選択肢を表示し、DeepSeek の API キー設定を表示しています。",
    previewCaption: "macOS の切り替えパネル", providers: "対応プロバイダー",
    openAI: "Codex Desktop の通常の起動設定を使用します。",
    deepSeek: "DeepSeek Flash 1017 の API キーをメニューから設定できます。",
    glmCoding: "BigModel または Z.ai のプラン枠で GLM-5.4 を使用します。",
    kimiCoding: "Kimi Code のプラン枠で kimi-for-coding を使用します。",
    glmAPI: "BigModel または Z.ai の従量課金で GLM-5.3 を使用します。",
    kimiAPI: "Moonshot Open Platform の従量課金で Kimi K3 を使用します。",
    geminiAPI: "Google AI Studio の API キーで Gemini 3.8 Flash を使用します。",
    claudeAPI: "Claude ワークスペースの API キーで Claude Sonnet 5.5 を使用します。",
    grokAPI: "xAI Responses API で Grok 4.7 を使用します。",
    setupTitle: "インストール後の使い方", openTitle: "切り替えパネルを開く",
    openBody: "公式の ChatGPT Desktop をインストールします。切り替えアプリを「アプリケーション」に移動し、メニューバーから開きます。",
    chooseTitle: "プロバイダーを選ぶ", chooseBody: "メニューから API キーを macOS のキーチェーンに保存します。GLM と Kimi では、キーを発行した地域も選びます。",
    confirmTitle: "確認して新しいセッションを開始", confirmBody: "実行中のタスクを終えてから確認します。ChatGPT が再起動したら、ローカルの Codex セッションを新しく開始できます。",
    glmGuide: "GLM と Kimi の設定", deepSeekGuide: "DeepSeek の設定",
    otherGuide: "Gemini、Claude、Grok の設定",
    footer: "独立したオープンソースツールです。各ロゴはそれぞれの権利者に帰属します。", license: "MIT ライセンス"
  }
};

const root = document.documentElement;
const panelPreview = document.getElementById("panel-preview");
const language = preference("language", (value) => {
  setLanguage(value);
  syncPreview();
  savePreference(languageKey, value);
  const url = new URL(location.href);
  url.searchParams.set("lang", value);
  history.replaceState(null, "", url);
});
const theme = preference("theme", (value) => {
  setTheme(value);
  savePreference(themeKey, value);
});
const darkPreference = matchMedia("(prefers-color-scheme: dark)");
const languageKey = "provider-switcher.language";
const themeKey = "provider-switcher.theme";

function preference(id, onSelect) {
  const control = document.getElementById(id);
  const trigger = control.querySelector(".preference-trigger");
  const label = control.querySelector("#" + id + "-value");
  const menu = control.querySelector(".preference-menu");
  const options = [...menu.querySelectorAll("[role=option]")];
  let selected = options.findIndex((option) => option.getAttribute("aria-selected") === "true");

  function open() {
    menu.hidden = false;
    trigger.setAttribute("aria-expanded", "true");
    options[selected].focus({ preventScroll: true });
  }

  function close(returnFocus = false) {
    menu.hidden = true;
    trigger.setAttribute("aria-expanded", "false");
    if (returnFocus) trigger.focus({ preventScroll: true });
  }

  trigger.addEventListener("click", () => menu.hidden ? open() : close(true));
  trigger.addEventListener("keydown", (event) => {
    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
      event.preventDefault();
      open();
    }
  });
  for (const option of options) {
    option.addEventListener("click", () => {
      onSelect(option.dataset.value);
      close(true);
    });
  }
  menu.addEventListener("keydown", (event) => {
    const index = options.indexOf(event.target);
    let next;
    switch (event.key) {
      case "ArrowDown": next = (index + 1) % options.length; break;
      case "ArrowUp": next = (index - 1 + options.length) % options.length; break;
      case "Home": next = 0; break;
      case "End": next = options.length - 1; break;
      case "Escape":
        event.preventDefault();
        close(true);
        return;
      default: return;
    }
    event.preventDefault();
    options[next].focus({ preventScroll: true });
  });
  control.addEventListener("focusout", (event) => {
    if (!menu.hidden && !control.contains(event.relatedTarget)) close();
  });
  document.addEventListener("pointerdown", (event) => {
    if (!menu.hidden && !control.contains(event.target)) close();
  });

  return {
    get value() { return options[selected].dataset.value; },
    setValue(value) {
      selected = options.findIndex((option) => option.dataset.value === value);
      for (const [index, option] of options.entries()) {
        option.setAttribute("aria-selected", String(index === selected));
      }
      label.textContent = options[selected].textContent;
    }
  };
}

function readPreference(key) {
  try { return localStorage.getItem(key); }
  catch { return null; }
}

function savePreference(key, value) {
  try { localStorage.setItem(key, value); }
  catch { /* The setting still applies to the current page. */ }
}

function supportedLanguage(tag) {
  const value = tag?.toLowerCase();
  if (!value) return null;
  if (/^zh(?:-|$)/.test(value)) {
    if (value.includes("-hans")) return "zh-Hans";
    return /-(?:hant|tw|hk|mo)(?:-|$)/.test(value) ? "zh-Hant" : "zh-Hans";
  }
  if (/^ja(?:-|$)/.test(value)) return "ja";
  if (/^en(?:-|$)/.test(value)) return "en";
  return null;
}

function setLanguage(locale) {
  const strings = translations[locale];
  for (const element of document.querySelectorAll("[data-i18n]")) {
    element.textContent = strings[element.dataset.i18n];
  }
  for (const attribute of ["alt", "aria-label"]) {
    for (const element of document.querySelectorAll(`[data-i18n-${attribute}]`)) {
      element.setAttribute(attribute, strings[element.getAttribute(`data-i18n-${attribute}`)]);
    }
  }
  root.lang = locale;
  language.setValue(locale);
  theme.setValue(theme.value);
  document.querySelector('meta[name="description"]').content = strings.lead;
}

function setTheme(mode) {
  if (mode === "system") delete root.dataset.theme;
  else root.dataset.theme = mode;
  theme.setValue(mode);
  syncAppearance();
}

function effectiveTheme() {
  if (theme.value !== "system") return theme.value;
  return darkPreference.matches ? "dark" : "light";
}

function syncAppearance() {
  const mode = effectiveTheme();
  document.querySelector('meta[name="theme-color"]').content = mode === "dark" ? "#111523" : "#f5f8fc";
  syncPreview(mode);
}

function syncPreview(mode = effectiveTheme()) {
  const locale = root.lang;
  const source = `assets/previews/${locale}-${mode}.png?v=1.2.3`;
  if (panelPreview.getAttribute("src") === source) return;
  panelPreview.height = locale === "ja" ? 1372 : 1316;
  panelPreview.src = source;
}

const queryLanguage = new URL(location.href).searchParams.get("lang");
setLanguage(
  supportedLanguage(queryLanguage)
  ?? supportedLanguage(readPreference(languageKey))
  ?? (navigator.languages ?? [navigator.language]).map(supportedLanguage).find(Boolean)
  ?? "en"
);
const savedTheme = readPreference(themeKey);
setTheme(savedTheme === "light" || savedTheme === "dark" ? savedTheme : "system");

darkPreference.addEventListener("change", syncAppearance);
document.getElementById("preferences").hidden = false;
