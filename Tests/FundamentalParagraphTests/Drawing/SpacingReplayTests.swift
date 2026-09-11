@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Foundation
import Testing

@MainActor
struct SpacingReplayTests
{
    @Test func everyAcceptedParagraphLineRendersWithTheSameSource() throws
    {
        var lines = 0
        var adjusted = 0
        let cases = try ComposerReplayFixture.paragraphs()
        for (name, result) in cases
        {
            try ParagraphAssertions.verify(result)
            let plans = result.segments.flatMap(\.lines)
            for (index, plan) in plans.enumerated()
            {
                let line = try SpacedNativeLine(plan)
                try SpacingAssertions.geometry(line)
                let raster = try SpacingFixture.raster(line)
                SpacingAssertions.unclipped(
                    raster, empty: plan.shaped.display.units.isEmpty
                )
                try SpacingEvidence.write(
                    "replay-\(name)-\(index)", line: line, raster: raster
                )
                lines += 1
                adjusted += plan.spacing.adjustment == 0 ? 0 : 1
            }
        }
        #expect(lines == 92 && adjusted == 6)
        try PatternEvidence.write("replay", group: "spacing-controls", record: [
            "paragraphs": cases.count,
            "lines": lines, "nonzeroAdjustments": adjusted
        ])
    }
}
