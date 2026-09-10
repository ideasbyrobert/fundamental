import AppKit
import CoreText

@MainActor
struct NativeListMeasure
{
    let column: Double
    let inset: Double

    init(source: LayoutListMarkerSource, font: NSFont) throws
    {
        var digitWidth = 0.0
        for digit in 0 ... 9
        {
            digitWidth = max(digitWidth, try Self.advance(
                String(digit), font: font
            ))
        }
        let digits: Int
        if case .numbered = source.role
        {
            digits = String(source.position.count).count
        }
        else
        {
            digits = 1
        }
        let column = Double(digits) * digitWidth
            + (try Self.advance(".", font: font))
        let inset = column + 2 * (try Self.advance(" ", font: font))
        guard column.isFinite, column > 0, inset.isFinite, inset > column
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        self.column = column
        self.inset = inset
    }

    private static func advance(_ text: String, font: NSFont) throws -> Double
    {
        let line = CTLineCreateWithAttributedString(NSAttributedString(
            string: text, attributes: [.font: font]
        ))
        let width = CTLineGetTypographicBounds(line, nil, nil, nil)
        guard width.isFinite, width > 0
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        return width
    }
}
