@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
enum ParagraphAssertions
{
    static func verify(_ result: ParagraphComposition) throws
    {
        let source = result.collection.source
        let lines = result.segments.flatMap(\.lines)
        #expect(result.segments.count == source.source.lines.count)
        var cursor = 0
        var recovered: [UInt16] = []
        for line in lines
        {
            #expect(line.sourceRange.lowerBound == cursor)
            #expect(source.source.isBoundary(line.sourceRange.upperBound))
            let prefix = try ExplicitFixture.reconstructed(
                line.shaped.display.body.slice
            )
            let original = prefix + line.tail.flatMap
            {
                fragment in
                let run = source.paragraph.runs[fragment.runIndex]
                return Array(Array(run.text.utf16)[fragment.runRange])
            }
            #expect(original == Array(source.source.utf16[line.sourceRange]))
            recovered += original
            cursor = line.sourceRange.upperBound
            #expect(line.spacing.advance <= result.width)
            #expect(line.spacing.advance.isFinite)
            let planned = line.metrics.advance
                + Double(line.metrics.gaps.count) * line.spacing.adjustment
            #expect(abs(planned - line.spacing.advance) < 0.000001)
            for gap in line.metrics.gaps
            {
                #expect(line.spacing.adjustment >= -0.25 * gap.advance)
                #expect(line.spacing.adjustment <= 0.75 * gap.advance)
                #expect(gap.advance + line.spacing.adjustment > 0)
            }
            let units = line.shaped.display.units
            #expect(Set(line.shaped.runs.flatMap(\.glyphs)
                .flatMap(\.displayRange)) == Set(units.indices))
            for glyph in line.shaped.runs.flatMap(\.glyphs)
            {
                try AutomaticAssertions.sources(
                    line.shaped.display, range: glyph.displayRange,
                    values: glyph.sources
                )
            }
        }
        #expect(cursor == source.source.utf16.count)
        #expect(recovered == source.source.utf16)
    }

    static func scoresEqual(
        _ actual: ParagraphScore, _ expected: ParagraphScore
    )
    {
        #expect(actual.emergency == expected.emergency)
        #expect(actual.ragged == expected.ragged)
        #expect(abs(actual.demerits - expected.demerits) < 0.000001)
    }
}
