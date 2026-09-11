import FundamentalParagraph
import Foundation
import FundamentalDocument
import FundamentalNativeWrapping

@MainActor
package struct HyphenatedShapedLine
{
    package let display: HyphenatedDisplay
    package let measurement: NativeWrappingLine
    package let runs: [MappedNativeRun<HyphenatedGlyphSource>]

    package init(
        _ collection: ParagraphHyphens, range: Range<Int>,
        end: HyphenatedLineEnd = .unbroken, inlineOffset: Double = 0,
        attributes: (SemanticRun) throws -> [NSAttributedString.Key: Any]
    ) throws
    {
        let display = try HyphenatedDisplay(
            collection, range: range, end: end
        )
        let attributed = try display.attributed(using: attributes)
        self.display = display
        measurement = try NativeParagraphShaping.measure(
            attributed, inlineOffset: inlineOffset
        )
        runs = try NativeParagraphShaping.runs(
            measurement, displayLength: display.units.count,
            sources: display.sources(in:)
        )
    }
}
