@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import CoreText
import Foundation
import Testing

@MainActor
enum ShapingAssertions
{
    static func compare(
        _ subject: ExplicitShapedLine, text: String, reference: CTLine
    ) throws
    {
        #expect(subject.display.units == Array(text.utf16))
        _ = try ExplicitFixture.reconstructed(subject.display.slice)
        #expect(abs(subject.measurement.advance - CTLineGetTypographicBounds(
            reference, nil, nil, nil
        )) < 0.000001)
        #expect(abs(subject.measurement.trailingWhitespace
            - CTLineGetTrailingWhitespaceWidth(reference)) < 0.000001)
        let actual = subject.runs.map
        {
            run in
            [
                "font": run.font.postScript, "size": run.font.pointSize,
                "glyphs": run.glyphs.map(\.identifier),
                "indices": run.glyphs.map(\.stringIndex),
                "positions": run.glyphs.map { [$0.position.x, $0.position.y] },
                "advances": run.glyphs.map {
                    [$0.advance.width, $0.advance.height]
                }
            ] as [String: Any]
        }
        let options: JSONSerialization.WritingOptions = .sortedKeys
        #expect(try JSONSerialization.data(
            withJSONObject: actual, options: options
        ) == JSONSerialization.data(
            withJSONObject: ShapingReference.rawRuns(reference),
            options: options
        ))
        let glyphs = subject.runs.flatMap(\.glyphs)
        #expect(Set(glyphs.flatMap(\.displayRange))
            == Set(subject.display.units.indices))
        for glyph in glyphs
        {
            try sources(subject.display, query: glyph.displayRange,
                        actual: glyph.sources)
        }
    }

    static func sources(
        _ display: ExplicitDisplayMap, query: Range<Int>,
        actual: [ExplicitDisplayAtom]
    ) throws
    {
        var expected: [[Int]] = []
        var position = 0
        for atom in display.slice.atoms
        {
            if atom.kind == .suppressedSoftHyphen
            {
                continue
            }
            for local in atom.fragment.runRange
            {
                if query.contains(position)
                {
                    expected.append([
                        atom.fragment.runIndex, local,
                        atom.fragment.paragraphRange.lowerBound
                            + local - atom.fragment.runRange.lowerBound
                    ])
                }
                position += 1
            }
        }
        let recovered = actual.flatMap
        {
            atom in
            atom.fragment.runRange.map
            {
                [atom.fragment.runIndex, $0,
                 atom.fragment.paragraphRange.lowerBound
                    + $0 - atom.fragment.runRange.lowerBound]
            }
        }
        #expect(recovered == expected)
    }
}
