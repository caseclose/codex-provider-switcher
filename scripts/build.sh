#!/bin/bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd -P)"
output="${1:-$root/dist}"
mkdir -p "$output"
output="$(cd "$output" && pwd -P)"
app="$output/Codex Provider Switcher.app"
if [[ -e "$app" ]]; then
    printf 'Bundle already exists. Choose an empty output directory: %s\n' "$output" >&2
    exit 1
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
staged="$work/Codex Provider Switcher.app"
resources="$staged/Contents/Resources"
binary="$staged/Contents/MacOS/CodexProviderSwitcher"
mkdir -p "$resources" "$(dirname "$binary")" "$work/AppIcon.iconset"
cp "$root/Resources/Info.plist" "$staged/Contents/"
cp "$root/Resources/"*-models.json "$root/Resources/provider-codex" "$root/Resources/deepseek-codex" "$resources/"
cp "$root/Resources/ProviderIcons/"*.png "$resources/"
chmod 755 "$resources/provider-codex" "$resources/deepseek-codex"

# OpenAI and DeepSeek own these marks. They identify the configured providers in the UI.
curl --fail --silent --show-error --location 'https://cdn.openai.com/brand/openai-logos.zip' -o "$work/openai-logos.zip"
for variant in Black White; do
    unzip -p "$work/openai-logos.zip" "OpenAI-logos/SVGs/OAI_OpenAI-Blossom_$variant.svg" > "$work/openai-$variant.svg"
    sips -s format png -Z 256 "$work/openai-$variant.svg" --out "$resources/OpenAI$variant.png" >/dev/null
    sips --cropToHeightWidth 160 160 "$resources/OpenAI$variant.png" >/dev/null
done
curl --fail --silent --show-error --location     'https://raw.githubusercontent.com/deepseek-ai/awesome-deepseek-integration/main/docs/_logo%20svg/ICON.svg'     -o "$work/deepseek.svg"
sips -s format png --resampleWidth 240 "$work/deepseek.svg" --out "$resources/DeepSeekBlue.png" >/dev/null

swiftc -parse-as-library -O "$root/Sources/AppIconArtwork.swift" -o "$work/render-app-icon"
"$work/render-app-icon" "$work/AppIcon.iconset"
iconutil -c icns "$work/AppIcon.iconset" -o "$resources/AppIcon.icns"

sources=(
    "$root/Sources/DesktopLauncher.swift"
    "$root/Sources/Provider.swift"
    "$root/Sources/ProviderArtwork.swift"
    "$root/Sources/ProviderKeychain.swift"
    "$root/Sources/ProviderPanel.swift"
    "$root/Sources/Switcher.swift"
)
for arch in arm64 x86_64; do
    swiftc -target "$arch-apple-macosx14.0" -swift-version 5 -O "${sources[@]}" -o "$work/$arch"
done
lipo -create "$work/arm64" "$work/x86_64" -output "$binary"
cp "$root/LICENSE" "$root/THIRD_PARTY_NOTICES.md" "$resources/"
codesign --force --sign - "$staged"
codesign --verify --strict "$staged"
ditto "$staged" "$app"
printf '%s\n' "$app"
