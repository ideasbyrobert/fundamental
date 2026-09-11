import AppKit
import CoreText
import FundamentalWrapping

@MainActor
package struct NativeCodeWrapping
{
    package let plan: WrappingPlan
    package let lines: [NativeWrappingLine]
    package let measuredFragments: Int

    package static func make(
        _ input: NSAttributedString, font: NSFont, width: Double
    ) -> Self?
    {
        guard width.isFinite, width > 0
        else
        {
            return nil
        }
        let spaces = String(repeating: " ",
                            count: CodeWrappingPolicy.indentationSpaces)
        let unit = CTLineGetTypographicBounds(
            CTLineCreateWithAttributedString(NSAttributedString(
                string: spaces, attributes: [.font: font]
            )), nil, nil, nil
        )
        guard unit.isFinite, unit > 0
        else
        {
            return nil
        }
        let paragraph = NSMutableParagraphStyle()
        paragraph.tabStops = []
        paragraph.defaultTabInterval = min(unit, width)
        paragraph.baseWritingDirection = .leftToRight
        let attributed = NSMutableAttributedString(attributedString: input)
        attributed.addAttribute(.paragraphStyle, value: paragraph.copy(),
            range: NSRange(location: 0, length: attributed.length))
        guard let text = NativeWrappingText(attributed)
        else
        {
            return nil
        }
        var wrapper = NativeCodeWrapper(text: text, width: width, unit: unit)
        return wrapper.wrap()
    }
}
