@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
struct StagedReplayTests
{
    @Test func sourceAndFormattingCasesKeepExactNativeOutput() throws
    {
        for (name, original) in try ComposerReplayFixture.paragraphs()
        {
            _ = try StagedAssertions.compare(
                "replay-" + name, original: original, width: original.width
            )
        }
    }

    @Test func widthAndSizeSweepKeepsExactNativeOutput() throws
    {
        for fixture in try TerminalSweepFixture.sources()
        {
            for size in [18.0, 36]
            {
                let seed = try ParagraphFixture.compose(
                    fixture.source, width: 800, size: size
                )
                for measure in fixture.widths
                {
                    let name = "sweep-\(fixture.name)-\(measure)-\(Int(size))"
                    _ = try StagedAssertions.compare(
                        name, original: seed,
                        width: Double(measure) * size / 18
                    )
                }
            }
        }
    }
}
