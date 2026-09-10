import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutListLineTests
{
    @MainActor
    @Test("empty and decorated list source preserve native source geometry")
    func richSource() throws
    {
        let traits: [SemanticInlineTrait] = [
            .strong, .emphasis, .underline, .strikethrough,
            .inlineCode, .superscript, .subscriptText
        ]
        let variants = try LayoutEmptyFontFixture.emptyRuns()
            + traits.map { [LayoutFixture.direct("Ag", traits: [$0])] }
            + [[LayoutFixture.scoped("Linked e\u{301}😀\nSecond line")]]
        let native = NativeTextKit2Layout()
        for kind in SemanticListKind.allCases
        {
            for runs in variants
            {
                let item = try LayoutListLineFixture.item(kind, runs: runs)
                let lines = try native.proseLines(
                    item.prose, source: item.block, width: 320, originY: 37.5
                )
                let first = try #require(lines.first)
                let marker = try #require(first.marker)
                let font = try native.proseFont(.body)
                let inset = first.baseline.x
                let source = try native.textLines(
                    runs: item.prose.runs, width: 320 - inset,
                    originX: inset, originY: 37.5, font: font,
                    pointContext: .block(item.block.blockID)
                )
                #expect(lines.count == source.count)
                for (actual, expected) in zip(lines, source)
                {
                    #expect(actual.text == expected.text)
                    #expect(actual.sourceSlices == expected.sourceSlices)
                    #expect(actual.glyphRuns == expected.glyphRuns)
                    #expect(actual.caretStops == expected.caretStops)
                    #expect(actual.baseline == expected.baseline)
                    #expect(actual.defaultFont == expected.defaultFont)
                    #expect(actual.frame.minY <= expected.frame.minY)
                    #expect(actual.frame.maxY >= expected.frame.maxY)
                }
                #expect(marker.baseline.y == first.baseline.y)
                #expect(marker.glyphRuns.allSatisfy
                {
                    $0.font == first.defaultFont
                        && $0.sourceSlices.isEmpty && $0.decorations.isEmpty
                })
                #expect(first.frame.minX <= marker.inkBounds.minX)
                #expect(first.frame.maxX >= marker.inkBounds.maxX)
                #expect(first.frame.minY <= marker.inkBounds.minY)
                #expect(first.frame.maxY >= marker.inkBounds.maxY)
                LayoutListLineFixture.expectSource(
                    lines, text: runs.map(\.text).joined(), block: item.block
                )
            }
        }
    }
}
