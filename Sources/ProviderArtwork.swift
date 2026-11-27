import AppKit

enum ProviderArtwork {
    private static let statusBadgeSize = NSSize(width: 24, height: 20)
    static let statusTrailingInset: CGFloat = 6
    static let statusItemLength = statusBadgeSize.width + statusTrailingInset + 6

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
        let mark = trimmedMark(logo)
        let image = statusBadge { bounds in
            let foreground = dark ? NSColor.white : NSColor.black
            let outline = NSBezierPath(roundedRect: bounds.insetBy(dx: 0.75, dy: 1.25),
                                       xRadius: 4.75, yRadius: 4.75)
            outline.lineWidth = 0.8
            foreground.withAlphaComponent(0.55).setStroke()
            outline.stroke()

            let edgeInset: CGFloat = 4
            let scale = min(9.5 / mark.size.width, 10 / mark.size.height)
            let markSize = NSSize(width: mark.size.width * scale, height: mark.size.height * scale)
            mark.draw(in: NSRect(x: bounds.minX + edgeInset, y: bounds.midY - markSize.height / 2,
                                 width: markSize.width, height: markSize.height),
                      from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: [.interpolation: NSImageInterpolation.high])

            let arrows = NSBezierPath()
            arrows.lineWidth = 1
            arrows.lineCapStyle = .round
            arrows.lineJoinStyle = .round
            let right = bounds.maxX - edgeInset - arrows.lineWidth / 2
            let left = right - 4.5
            let top = bounds.midY + 1.75
            let bottom = bounds.midY - 1.75
            let head: CGFloat = 1.4
            arrows.move(to: NSPoint(x: left, y: top))
            arrows.line(to: NSPoint(x: right, y: top))
            arrows.move(to: NSPoint(x: right - head, y: top + head))
            arrows.line(to: NSPoint(x: right, y: top))
            arrows.line(to: NSPoint(x: right - head, y: top - head))
            arrows.move(to: NSPoint(x: right, y: bottom))
            arrows.line(to: NSPoint(x: left, y: bottom))
            arrows.move(to: NSPoint(x: left + head, y: bottom + head))
            arrows.line(to: NSPoint(x: left, y: bottom))
            arrows.line(to: NSPoint(x: left + head, y: bottom - head))
            foreground.withAlphaComponent(0.9).setStroke()
            arrows.stroke()
        }
        image.accessibilityDescription = provider.title
        return image
    }

    static func statusFallback(accessibilityDescription: String) -> NSImage? {
        guard let symbol = NSImage(systemSymbolName: "arrow.left.arrow.right", accessibilityDescription: nil)?
            .withSymbolConfiguration(.init(pointSize: 14, weight: .semibold)) else { return nil }
        let image = statusBadge { bounds in
            symbol.draw(at: NSPoint(x: bounds.midX - symbol.size.width / 2,
                                    y: bounds.midY - symbol.size.height / 2),
                        from: .zero, operation: .sourceOver, fraction: 1)
        }
        image.isTemplate = true
        image.accessibilityDescription = accessibilityDescription
        return image
    }

    private static func statusBadge(draw: @escaping (NSRect) -> Void) -> NSImage {
        let size = NSSize(width: statusBadgeSize.width + statusTrailingInset, height: statusBadgeSize.height)
        return NSImage(size: size, flipped: false) { _ in
            draw(NSRect(origin: .zero, size: statusBadgeSize))
            return true
        }
    }

    // Provider assets include different amounts of transparent padding.
    private static func trimmedMark(_ logo: NSImage) -> NSImage {
        guard let bitmap = logo.representations.first as? NSBitmapImageRep,
              bitmap.hasAlpha, let raster = bitmap.cgImage else { return logo }

        var visible = CGRect.null
        for y in 0..<bitmap.pixelsHigh {
            for x in 0..<bitmap.pixelsWide where (bitmap.colorAt(x: x, y: y)?.alphaComponent ?? 0) >= 0.15 {
                visible = visible.union(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        guard !visible.isNull,
              let cropped = raster.cropping(to: visible.insetBy(dx: -1, dy: -1)) else { return logo }
        return NSImage(cgImage: cropped, size: NSSize(width: cropped.width, height: cropped.height))
    }
}
