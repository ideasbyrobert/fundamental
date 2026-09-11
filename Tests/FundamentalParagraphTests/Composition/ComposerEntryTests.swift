import FundamentalNativeParagraph
import Testing

@MainActor
struct ComposerEntryTests
{
    @Test func invalidWidthsFailBeforeResolvingOriginalAttributes() throws
    {
        let source = try AutomaticFixture.text("aa bb")
        var calls = 0
        for width in [0, -1, Double.nan, .infinity, -.infinity]
        {
            #expect(throws: ParagraphFailure.invalidWidth)
            {
                try ParagraphComposition(source, width: width)
                {
                    calls += 1
                    return try ShapingFixture.attributes($0, size: 18)
                }
            }
            #expect(throws: ParagraphFailure.invalidWidth)
            {
                try StagedParagraphComposition(source, width: width)
                {
                    calls += 1
                    return try ShapingFixture.attributes($0, size: 18)
                }
            }
        }
        #expect(calls == 0)
    }

    @Test func identicalAndEmptyRunsResolveOnceAcrossRecomposition() throws
    {
        let source = try WordFixture.source([
            WordFixture.run("aa"), WordFixture.run("aa"), WordFixture.run("")
        ])
        let collection = try AutomaticFixture.collection(source)
        var calls = 0
        let paragraph = try ParagraphComposition(collection, width: 200)
        {
            run in
            calls += 1
            return try ShapingFixture.attributes(run, size: Double(calls * 10))
        }
        #expect(calls == 3)
        let line = try #require(paragraph.segments.first?.lines.first)
        #expect(line.shaped.runs.map(\.font.pointSize) == [10, 20])
        for width in [40.0, 100, 200]
        {
            let replay = try StagedParagraphComposition(paragraph, width: width)
            try ParagraphAssertions.verify(replay.paragraph)
            #expect(replay.paragraph.collection.source.paragraph
                == source.paragraph)
        }
        #expect(calls == 3)
    }
}
