import AppKit
import CoreText
import Testing

@testable import FundamentalLayout

@MainActor
struct LayoutListRasterFixture
{
    let storage: NSTextContentStorage
    let manager: NSTextLayoutManager
    let font: NSFont
    let fonts: [LayoutFontIdentity: CTFont]

    static func sourceInset(_ marker: LayoutListMarker) throws -> Double
    {
        let space = CTLineCreateWithAttributedString(NSAttributedString(
            string: " ",
            attributes: [.font: try LayoutMarkerRasterFixture.font()]
        ))
        return marker.baseline.x + marker.advance
            + 2 * CTLineGetTypographicBounds(space, nil, nil, nil)
    }

    init(text: String, width: Double) throws
    {
        let font = try LayoutMarkerRasterFixture.font()
        let attributed = NSAttributedString(string: text, attributes: [
            .font: font, .foregroundColor: NSColor.black
        ])
        let storage = NSTextContentStorage()
        let manager = NSTextLayoutManager()
        let container = NSTextContainer(size: CGSize(
            width: width, height: .greatestFiniteMagnitude
        ))
        container.lineFragmentPadding = 0
        storage.addTextLayoutManager(manager)
        manager.textContainer = container
        storage.attributedString = attributed
        manager.ensureLayout(for: storage.documentRange)
        let native = NativeTextKit2Layout()
        var fonts = [try native.fontIdentity(font as CTFont): font as CTFont]
        let line = CTLineCreateWithAttributedString(attributed)
        for run in CTLineGetGlyphRuns(line) as! [CTRun]
        {
            let attributes = CTRunGetAttributes(run) as NSDictionary
            let fallback = attributes[kCTFontAttributeName] as! CTFont
            fonts[try native.fontIdentity(fallback)] = fallback
        }
        self.storage = storage
        self.manager = manager
        self.font = font
        self.fonts = fonts
    }

    func expected(in context: CGContext, inset: Double,
                  marker: LayoutListMarker)
    {
        manager.enumerateTextLayoutFragments(
            from: storage.documentRange.location,
            options: [.ensuresLayout, .ensuresExtraLineFragment]
        )
        {
            fragment in
            fragment.draw(at: CGPoint(
                x: inset + fragment.layoutFragmentFrame.minX,
                y: fragment.layoutFragmentFrame.minY
            ), in: context)
            return true
        }
        context.saveGState()
        context.translateBy(x: marker.baseline.x, y: marker.baseline.y)
        context.scaleBy(x: 1, y: -1)
        context.textMatrix = .identity
        context.textPosition = .zero
        CTLineDraw(CTLineCreateWithAttributedString(NSAttributedString(
            string: marker.source.label, attributes: [.font: font]
        )), context)
        context.restoreGState()
    }
}
