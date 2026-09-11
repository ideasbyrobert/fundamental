@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
struct StagedBoundaryTests
{
    @Test func authoredEndingsAndSingleLinesKeepExactOutput() throws
    {
        let endings = ["\n", "\r", "\r\n", "\u{B}", "\u{C}", "\u{85}",
                       "\u{2028}", "\u{2029}"]
        for (index, ending) in endings.enumerated()
        {
            let original = try ParagraphFixture.compose(
                AutomaticFixture.text("aa b c" + ending + "tail"), width: 30
            )
            _ = try StagedAssertions.compare(
                "hard-\(index)", original: original, width: 30
            )
        }
        for (index, text) in ["", " ", "\u{AD}", "hello", "👩‍💻"].enumerated()
        {
            let original = try ParagraphFixture.compose(
                AutomaticFixture.text(text), width: 100
            )
            _ = try StagedAssertions.compare(
                "single-\(index)", original: original, width: 100
            )
        }
    }

    @Test func necessaryEmergencyBreaksUseTheSharedCacheFallback() throws
    {
        let original = try StagedFixture.shortEnding()
        let result = try StagedAssertions.compare(
            "short-fallback", original: original, width: original.width
        )
        #expect(result.searches[0].usedFallback)
        #expect(result.searches[0].path.score.emergency == 4)
    }
}
