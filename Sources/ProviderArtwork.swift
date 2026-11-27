import AppKit

enum ProviderArtwork {
    static func logo(for provider: Provider, dark: Bool, in bundle: Bundle = .main) -> NSImage? {
        let name: String
        switch provider {
        case .openAI: name = dark ? "OpenAIWhite" : "OpenAIBlack"
        case .deepSeek: name = "DeepSeekBlue"
        case .glmCoding: name = "ZCode"
        case .glmAPI: name = "BigModel"
        case .kimiCoding: name = dark ? "KimiCodeDark" : "KimiCodeLight"
        case .kimiAPI: name = dark ? "KimiPlatformDark" : "KimiPlatformLight"
        case .geminiAPI: name = "Gemini"
        case .claudeAPI: name = "Claude"
        case .grokAPI: name = "Grok"
        }
        guard let url = bundle.url(forResource: name, withExtension: "png") else { return nil }
        return NSImage(contentsOf: url)
    }

    static func statusImage(for provider: Provider, dark: Bool, in bundle: Bundle = .main) -> NSImage? {
        guard let logo = logo(for: provider, dark: dark, in: bundle) else { return nil }
        let image = NSImage(size: NSSize(width: 24, height: 20), flipped: false) { _ in
            let foreground = dark ? NSColor.white : NSColor.black
            let outline = NSBezierPath(roundedRect: NSRect(x: 0.75, y: 1.25, width: 22.5, height: 17.5),
                                       xRadius: 4.75, yRadius: 4.75)
            outline.lineWidth = 0.8
            foreground.withAlphaComponent(0.55).setStroke()
            outline.stroke()

            let width: CGFloat = 10
            let height = width * logo.size.height / logo.size.width
            logo.draw(in: NSRect(x: 4, y: (20 - height) / 2, width: width, height: height),
                      from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: [.interpolation: NSImageInterpolation.high])

            let arrows = NSBezierPath()
            arrows.lineWidth = 1
            arrows.lineCapStyle = .round
            arrows.lineJoinStyle = .round
            arrows.move(to: NSPoint(x: 16, y: 10.75))
            arrows.line(to: NSPoint(x: 21, y: 10.75))
            arrows.move(to: NSPoint(x: 19.55, y: 12.2))
            arrows.line(to: NSPoint(x: 21, y: 10.75))
            arrows.line(to: NSPoint(x: 19.55, y: 9.3))
            arrows.move(to: NSPoint(x: 21, y: 7.25))
            arrows.line(to: NSPoint(x: 16, y: 7.25))
            arrows.move(to: NSPoint(x: 17.45, y: 8.7))
            arrows.line(to: NSPoint(x: 16, y: 7.25))
            arrows.line(to: NSPoint(x: 17.45, y: 5.8))
            let inset = AffineTransform(translationByX: -0.8, byY: 1)
            arrows.transform(using: inset)
            foreground.withAlphaComponent(0.9).setStroke()
            arrows.stroke()
            return true
        }
        image.accessibilityDescription = provider.title
        return image
    }
}
