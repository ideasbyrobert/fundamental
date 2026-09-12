import AppKit
import CoreText

@MainActor
struct WritingListMarker
{
    let label: String
    let frame: CGRect
    let origin: CGPoint
    private let line: CTLine

    init?(
        beside source: NSTextLineFragment,
        attributes: [NSAttributedString.Key: Any], paragraphOrigin: CGPoint
    )
    {
        guard let label = attributes[WritingTypography.marker] as? String,
              let font = attributes[.font] as? NSFont
        else
        {
            return nil
        }
        let spelling = NSAttributedString(string: label, attributes: [
            .font: font,
            NSAttributedString.Key(kCTForegroundColorAttributeName as String):
                NSColor.textColor.cgColor
        ])
        let line = CTLineCreateWithAttributedString(spelling)
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        let width = CTLineGetTypographicBounds(line, &ascent, &descent, nil)
        let bounds = source.typographicBounds
        let baseline = paragraphOrigin.y + bounds.minY + source.glyphOrigin.y
        let leading = paragraphOrigin.x + bounds.minX + source.glyphOrigin.x
        let origin = CGPoint(
            x: leading - font.pointSize * 0.5 - width,
            y: baseline
        )
        self.label = label
        self.line = line
        self.origin = origin
        frame = CGRect(x: origin.x, y: baseline - ascent,
                       width: width, height: ascent + descent)
    }

    func draw(in context: CGContext)
    {
        context.saveGState()
        context.textMatrix = CGAffineTransform(scaleX: 1, y: -1)
        context.textPosition = origin
        CTLineDraw(line, context)
        context.restoreGState()
    }
}
