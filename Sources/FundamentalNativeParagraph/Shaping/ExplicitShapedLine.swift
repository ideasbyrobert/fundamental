import FundamentalParagraph
import Foundation
import FundamentalDocument
import FundamentalNativeWrapping

@MainActor
package struct ExplicitShapedLine
{
    package let display: ExplicitDisplayMap
    package let measurement: NativeWrappingLine
    package let runs: [MappedNativeRun<ExplicitDisplayAtom>]

    package init(
        _ collection: ExplicitParagraphHyphens,
        range: Range<Int>, end: ExplicitSliceEnd = .unbroken,
        inlineOffset: Double = 0,
        attributes: (SemanticRun) throws -> [NSAttributedString.Key: Any]
    ) throws
    {
        let display = try ExplicitDisplayMap(
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
