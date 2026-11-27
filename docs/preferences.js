const translations = {
  "zh-Hans": {
    navigation: "项目导航", setupLink: "使用方法", language: "语言", theme: "主题",
    system: "跟随系统", light: "浅色", dark: "深色",
    platform: "macOS 菜单栏工具", headingFirst: "从菜单栏切换", headingSecond: "Codex 提供商",
    lead: "在 Codex Desktop 使用 OpenAI、DeepSeek、GLM 或 Kimi。GLM 与 Kimi 支持编程套餐和按量 API，可在面板中按地区保存密钥。",
    download: "下载 macOS 版", release: "查看 Release", compat: "macOS 14+ · Apple 芯片与 Intel · MIT",
    previewAlt: "切换面板列出六个提供商，当前使用 OpenAI，已选择 DeepSeek 等待确认。",
    previewCaption: "macOS 切换面板", providers: "支持的提供商",
    openAI: "沿用 Codex Desktop 的常规启动配置。",
    deepSeek: "DeepSeek Flash 1017，使用已有的 deepseek 配置。",
    glmCoding: "GLM-5.4，使用智谱 BigModel 或 Z.ai 的套餐额度。",
    kimiCoding: "kimi-for-coding，使用 Kimi Code 的套餐额度。",
    glmAPI: "GLM-5.3，使用智谱开放平台按量计费。",
    kimiAPI: "Kimi K3，使用月之暗面开放平台按量计费。",
    setupTitle: "安装后怎么用", openTitle: "打开切换器",
    openBody: "先安装官方 ChatGPT Desktop，再把切换器移到「应用程序」，从菜单栏打开。",
    chooseTitle: "选择提供商", chooseBody: "首次使用 GLM 或 Kimi，选择账号地区，再将对应的 API Key 存入 macOS 钥匙串。",
    confirmTitle: "确认并新建会话", confirmBody: "结束正在运行的任务后再确认。切换器会重新打开 ChatGPT，随后可以新建本地 Codex 会话。",
    glmGuide: "GLM 和 Kimi 配置", deepSeekGuide: "DeepSeek 配置",
    footer: "独立开源工具。提供商图标归各品牌所有。", license: "MIT 许可证"
  },
  "zh-Hant": {
    navigation: "專案導覽", setupLink: "使用方式", language: "語言", theme: "外觀",
    system: "跟隨系統", light: "淺色", dark: "深色",
    platform: "macOS 選單列工具", headingFirst: "從選單列切換", headingSecond: "Codex 供應商",
    lead: "在 Codex Desktop 使用 OpenAI、DeepSeek、GLM 或 Kimi。GLM 與 Kimi 支援程式設計方案和按量計費 API，可依地區在面板中儲存金鑰。",
    download: "下載 macOS 版", release: "查看版本發行", compat: "macOS 14+ · Apple 晶片與 Intel · MIT",
    previewAlt: "切換面板列出六個供應商，目前使用 OpenAI，已選擇 DeepSeek 等待確認。",
    previewCaption: "macOS 切換面板（簡體中文畫面示例）", providers: "支援的供應商",
    openAI: "沿用 Codex Desktop 的一般啟動設定。",
    deepSeek: "DeepSeek Flash 1017，使用現有的 deepseek 設定。",
    glmCoding: "GLM-5.4，使用智譜 BigModel 或 Z.ai 的方案額度。",
    kimiCoding: "kimi-for-coding，使用 Kimi Code 的方案額度。",
    glmAPI: "GLM-5.3，透過智譜開放平台按量計費。",
    kimiAPI: "Kimi K3，透過月之暗面開放平台按量計費。",
    setupTitle: "安裝後如何使用", openTitle: "打開切換器",
    openBody: "先安裝官方 ChatGPT Desktop，再將切換器移到「應用程式」，從選單列打開。",
    chooseTitle: "選擇供應商", chooseBody: "第一次使用 GLM 或 Kimi 時，選擇帳號地區，再將對應的 API 金鑰存入 macOS 鑰匙圈。",
    confirmTitle: "確認並開啟新對話", confirmBody: "先完成執行中的工作再確認。切換器會重新開啟 ChatGPT，接著就能開啟新的本機 Codex 對話。",
    glmGuide: "GLM 與 Kimi 設定", deepSeekGuide: "DeepSeek 設定",
    footer: "獨立開源工具。供應商圖示歸各品牌所有。", license: "MIT 授權條款"
  },
  en: {
    navigation: "Project navigation", setupLink: "Setup", language: "Language", theme: "Appearance",
    system: "System", light: "Light", dark: "Dark",
    platform: "macOS menu bar utility", headingFirst: "Switch Codex", headingSecond: "providers",
    lead: "Use OpenAI, DeepSeek, GLM, or Kimi in Codex Desktop. GLM and Kimi support coding plans and usage-based APIs, with separate keys for each region.",
    download: "Download for macOS", release: "View release", compat: "macOS 14+ · Apple silicon and Intel · MIT",
    previewAlt: "The switcher lists six providers. OpenAI is active and DeepSeek is selected, awaiting confirmation.",
    previewCaption: "The macOS switcher, shown in Simplified Chinese", providers: "Supported providers",
    openAI: "Uses your regular Codex Desktop startup settings.",
    deepSeek: "DeepSeek Flash 1017 with your existing deepseek configuration.",
    glmCoding: "GLM-5.4 with your BigModel or Z.ai coding plan quota.",
    kimiCoding: "kimi-for-coding with your Kimi Code plan quota.",
    glmAPI: "GLM-5.3 with usage-based billing through BigModel or Z.ai.",
    kimiAPI: "Kimi K3 with usage-based billing through Moonshot Open Platform.",
    setupTitle: "Get started", openTitle: "Open the switcher",
    openBody: "Install the official ChatGPT Desktop app first. Move the switcher to Applications, then open it from the menu bar.",
    chooseTitle: "Choose a provider", chooseBody: "When setting up GLM or Kimi, choose your account region and save the matching API key in macOS Keychain.",
    confirmTitle: "Confirm and start a new session", confirmBody: "Finish any active tasks before confirming. The switcher reopens ChatGPT so you can start a fresh local Codex session.",
    glmGuide: "Set up GLM and Kimi", deepSeekGuide: "Set up DeepSeek",
    footer: "Independent open-source utility. Provider marks belong to their respective owners.", license: "MIT License"
  },
  ja: {
    navigation: "プロジェクトのナビゲーション", setupLink: "使い方", language: "言語", theme: "外観",
    system: "システムに合わせる", light: "ライト", dark: "ダーク",
    platform: "macOS メニューバーアプリ", headingFirst: "メニューバーから", headingSecond: "Codex の接続先を切り替え",
    lead: "Codex Desktop で OpenAI、DeepSeek、GLM、Kimi を選べます。GLM と Kimi はコーディングプランと従量課金 API に対応し、地域ごとにキーを保存できます。",
    download: "macOS 版をダウンロード", release: "リリースを見る", compat: "macOS 14 以降 · Apple シリコンと Intel · MIT",
    previewAlt: "切り替えパネルに 6 つのプロバイダーを表示。OpenAI を使用中で、DeepSeek への切り替えを確認できます。",
    previewCaption: "macOS の切り替えパネル（簡体字中国語での表示例）", providers: "対応プロバイダー",
    openAI: "Codex Desktop の通常の起動設定を使用します。",
    deepSeek: "既存の deepseek 設定で DeepSeek Flash 1017 を使用します。",
    glmCoding: "BigModel または Z.ai のプラン枠で GLM-5.4 を使用します。",
    kimiCoding: "Kimi Code のプラン枠で kimi-for-coding を使用します。",
    glmAPI: "BigModel または Z.ai の従量課金で GLM-5.3 を使用します。",
    kimiAPI: "Moonshot Open Platform の従量課金で Kimi K3 を使用します。",
    setupTitle: "インストール後の使い方", openTitle: "切り替えパネルを開く",
    openBody: "公式の ChatGPT Desktop をインストールします。切り替えアプリを「アプリケーション」に移動し、メニューバーから開きます。",
    chooseTitle: "プロバイダーを選ぶ", chooseBody: "GLM や Kimi を初めて使用する場合は、アカウントの地域を選び、対応する API キーを macOS のキーチェーンに保存します。",
    confirmTitle: "確認して新しいセッションを開始", confirmBody: "実行中のタスクを終えてから確認します。ChatGPT が再起動したら、ローカルの Codex セッションを新しく開始できます。",
    glmGuide: "GLM と Kimi の設定", deepSeekGuide: "DeepSeek の設定",
    footer: "独立したオープンソースツールです。各ロゴはそれぞれの権利者に帰属します。", license: "MIT ライセンス"
  }
};

const root = document.documentElement;
const language = preference("language", (value) => {
  setLanguage(value);
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
  syncThemeColor();
}

function syncThemeColor() {
  const dark = theme.value === "dark" || (theme.value === "system" && darkPreference.matches);
  document.querySelector('meta[name="theme-color"]').content = dark ? "#111523" : "#f5f8fc";
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

darkPreference.addEventListener("change", syncThemeColor);
document.getElementById("preferences").hidden = false;
