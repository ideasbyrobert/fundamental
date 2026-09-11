@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
struct ParagraphSourceTests
{
    @Test func everyHardEndingAndBlankSegmentRetainsItsSource() throws
    {
        let endings = ["\n", "\r", "\r\n", "\u{B}", "\u{C}", "\u{85}",
                       "\u{2028}", "\u{2029}"]
        for (index, ending) in endings.enumerated()
        {
            let text = "aa \t" + ending + ending + " bb\t " + ending
            let result = try ParagraphFixture.compose(
                AutomaticFixture.text(text), width: 80
            )
            try ParagraphAssertions.verify(result)
            #expect(result.segments.count == 4)
            #expect(result.segments.allSatisfy
            {
                $0.lines.count == 1
            })
            #expect(result.segments[0].lines[0].shaped.display.text == "aa")
            #expect(result.segments[1].lines[0].shaped.display.text.isEmpty)
            #expect(result.segments[2].lines[0].shaped.display.text == " bb")
            #expect(result.segments[3].lines[0].sourceRange.isEmpty)
            try ParagraphEvidence.write("ending-\(index)", result: result)
        }
    }

    @Test func whitespaceGroupsAndEmergencyKindsRemainDistinct() throws
    {
        let value = try AutomaticFixture.text("  aa  \t bb \t")
        let cache = try ParagraphFixture.cache(value)
        let spaces = cache.candidates.breaks.filter { $0.kind.rank == 1 }
        #expect(spaces.map(\.position) == [2, 8])
        #expect(spaces.map(\.visibleEnd) == [0, 4])
        let terminal = try #require(cache.candidates.breaks.last)
        #expect(terminal.visibleEnd == 10 && terminal.position == 12)
        #expect(cache.candidates.breaks.filter { $0.position == 8 }.count == 2)
        let result = try ParagraphFixture.compose(value, width: 40)
        try ParagraphAssertions.verify(result)
        try ParagraphEvidence.write("whitespace", result: result)
    }

    @Test func emptySuppressedAndWhitespaceOnlySourcesStayWhole() throws
    {
        for (index, text) in ["", "\u{AD}", " \t ", "\u{AD}\u{AD}"]
            .enumerated()
        {
            let result = try ParagraphFixture.compose(
                AutomaticFixture.text(text), width: 20
            )
            try ParagraphAssertions.verify(result)
            #expect(result.segments.count == 1)
            #expect(result.segments[0].lines.count == 1)
            #expect(result.segments[0].lines[0].shaped.display.text.isEmpty)
            try ParagraphEvidence.write("empty-\(index)", result: result)
        }
    }

    @Test func longTokenUsesOnlyWholeCharacterEmergencyBreaks() throws
    {
        let value = try AutomaticFixture.text("WWWWWWWWWW")
        let result = try ParagraphFixture.compose(value, width: 40)
        try ParagraphAssertions.verify(result)
        let segment = try #require(result.segments.first)
        #expect(segment.lines.count == 5)
        #expect(segment.path.score.emergency == 4)
        #expect(segment.lines.allSatisfy
        {
            $0.shaped.display.text == "WW"
        })
        try ParagraphEvidence.write("emergency", result: result)
    }
}
