@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import CoreText
import Testing

@MainActor
struct SpacingCounterexampleTests
{
    @Test func widthOnlyNativeSuccessCannotSubstituteForGapOwnership() throws
    {
        for (name, text) in [
            ("tabs", "a b\tc d"), ("emoji", "👩‍💻 a раи\u{306}он")
        ]
        {
            for amount in [-0.5, 2.0]
            {
                let line = try SpacingFixture.text(text, amount: amount)
                try SpacingAssertions.geometry(line)
                let original = try #require(line.plan.shaped.measurement.native)
                let native = try #require(
                    CTLineCreateJustifiedLine(original, 1, line.advance)
                )
                #expect(abs(CTLineGetTypographicBounds(native, nil, nil, nil)
                    - line.advance) < 0.000001)
                let mapped = try (CTLineGetGlyphRuns(native) as! [CTRun]).map
                {
                    try MappedNativeRun(
                        $0, displayLength: line.plan.shaped.display.units.count,
                        sources: line.plan.shaped.display.sources(in:)
                    )
                }.flatMap(\.glyphs)
                let own = line.runs.flatMap(\.glyphs)
                #expect(mapped.count == own.count)
                let disagreements = zip(mapped, own).filter
                {
                    abs($0.position.x - $1.position.x) > 0.000001
                        || abs($0.advance.width - $1.advance.width) > 0.000001
                }.count
                #expect(disagreements == ((name == "tabs") ? 5
                    : (amount < 0 ? 3 : 0)))
                let raster = try SpacingFixture.raster(line)
                SpacingAssertions.unclipped(raster)
                try SpacingEvidence.write(
                    "counterexample-\(name)-\(amount)",
                    line: line, raster: raster
                )
                try PatternEvidence.write(
                    "\(name)-\(amount)", group: "spacing-controls", record: [
                        "advance": line.advance, "disagreements": disagreements,
                        "native": ShapingReference.rawRuns(native)
                    ]
                )
            }
        }
    }
}
