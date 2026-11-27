import AppKit
import ImageIO
import UniformTypeIdentifiers

@main
struct AppIconArtwork {
    static func main() throws {
        let folder = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        for points in [16, 32, 128, 256, 512] {
            for scale in 1...2 {
                let filename = "icon_\(points)x\(points)\(scale == 2 ? "@2x" : "").png"
                let image = icon(size: points * scale)
                let url = folder.appendingPathComponent(filename)
                guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)
                else { throw CocoaError(.fileWriteUnknown) }
                CGImageDestinationAddImage(destination, image, nil)
                guard CGImageDestinationFinalize(destination) else { throw CocoaError(.fileWriteUnknown) }
            }
        }
    }

    private static func icon(size: Int) -> CGImage {
        let space = CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                                space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        let scale = CGFloat(size) / 1024
        context.scaleBy(x: scale, y: scale)
        let tile = CGPath(roundedRect: CGRect(x: 100, y: 100, width: 824, height: 824),
                          cornerWidth: 188, cornerHeight: 188, transform: nil)
        context.saveGState()
        context.addPath(tile)
        context.clip()
        let gradient = CGGradient(colorsSpace: space,
                                  colors: [rgb(0x111B32), rgb(0x252D58), rgb(0x36517C)] as CFArray,
                                  locations: [0, 0.61, 1])!
        context.drawLinearGradient(gradient, start: CGPoint(x: 890, y: 120), end: CGPoint(x: 140, y: 950),
                                   options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        context.restoreGState()
        context.addPath(tile)
        context.setStrokeColor(rgb(0x8FBAF1, alpha: 0.29))
        context.setLineWidth(6)
        context.strokePath()

        context.setLineWidth(55)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        arrow(context, from: 277, to: 748, y: 630, color: rgb(0x80EEE0))
        arrow(context, from: 747, to: 276, y: 394, color: rgb(0xAFBCFF))
        return context.makeImage()!
    }

    private static func arrow(_ context: CGContext, from: CGFloat, to: CGFloat, y: CGFloat, color: CGColor) {
        let direction: CGFloat = to > from ? 1 : -1
        context.setStrokeColor(color)
        context.move(to: CGPoint(x: from, y: y))
        context.addLine(to: CGPoint(x: to, y: y))
        context.move(to: CGPoint(x: to - 108 * direction, y: y + 92))
        context.addLine(to: CGPoint(x: to, y: y))
        context.addLine(to: CGPoint(x: to - 108 * direction, y: y - 92))
        context.strokePath()
    }

    private static func rgb(_ value: UInt32, alpha: CGFloat = 1) -> CGColor {
        CGColor(srgbRed: CGFloat((value >> 16) & 255) / 255, green: CGFloat((value >> 8) & 255) / 255,
                blue: CGFloat(value & 255) / 255, alpha: alpha)
    }
}
