import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("Resolved native glyph witnesses")
struct LayoutGlyphWitnessTests
{
    @MainActor
    @Test("fallback fonts clusters transforms and decorations are fixed")
    func resolvedWitness() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct("A"),
            LayoutFixture.direct(
                "😀",
                traits: [.underline, .strikethrough]
            ),
            LayoutFixture.direct("office", traits: [.superscript])
        ]))
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 500)
        )
        guard case let .lines(fragment) = snapshot.firstFragment
        else
        {
            Issue.record("Expected a line fragment")
            return
        }
        let line = fragment.line
        #expect(line.glyphRuns.map(\.paintOrder)
            == Array(line.glyphRuns.indices))
        let emojiRuns = line.glyphRuns.filter
        {
            $0.sourceSlices.map(\.text).joined() == "😀"
        }
        #expect(!emojiRuns.isEmpty)
        #expect(emojiRuns.allSatisfy
        {
            $0.font.postScriptName != line.defaultFont.postScriptName
        })
        let emojiGlyphs = emojiRuns.flatMap(\.glyphs)
        #expect(emojiGlyphs.allSatisfy
        {
            $0.sourceSlices.map(\.text).joined() == "😀"
        })
        let decorations = emojiRuns.flatMap(\.decorations)
        #expect(decorations.map(\.kind)
            == [.underline, .strikethrough])
        #expect(decorations.allSatisfy
        {
            $0.sourceSlices.map(\.text).joined() == "😀"
        })
        let glyphEdges = line.glyphRuns.flatMap(\.glyphs).flatMap
        {
            [$0.position.x, $0.position.x + $0.advance.dx]
        }
        let maximumX = try #require(glyphEdges.max())
        let minimumX = try #require(glyphEdges.min())
        let glyphWidth = maximumX - minimumX
        #expect(abs(glyphWidth - line.frame.size.width) < 1)
        let raised = line.glyphRuns.first
        {
            $0.sourceSlices.map(\.text).joined() == "office"
        }
        #expect(raised?.style.baselineOffset ?? 0 > 0)
        for run in line.glyphRuns
        {
            #expect(run.font.variations.map(\.axis)
                == run.font.variations.map(\.axis).sorted())
            #expect(run.glyphs.allSatisfy
            {
                $0.position.x.isFinite && $0.position.y.isFinite
            })
        }
    }
}
