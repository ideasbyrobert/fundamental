import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

@Suite("Exact native layout source lineage")
struct LayoutExactSourceTests
{
    @MainActor
    @Test("block lines and carets retain exact run identity and ranges")
    func blockSource() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct("A😀"),
            LayoutFixture.direct("B")
        ]))
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 500)
        )
        guard case let .lines(fragment) = snapshot.firstFragment
        else
        {
            Issue.record("Expected one line fragment")
            return
        }
        let blockID = LayoutFixture.blockID(0)
        #expect(fragment.line.sourceSlices == [
            LayoutSourceSlice(
                source: .block(
                    blockID: blockID,
                    run: 0,
                    range: ProjectedUTF16Range(0 ..< 3)
                ),
                scope: .direct,
                range: 0 ..< 3,
                text: "A😀"
            ),
            LayoutSourceSlice(
                source: .block(
                    blockID: blockID,
                    run: 1,
                    range: ProjectedUTF16Range(3 ..< 4)
                ),
                scope: .direct,
                range: 3 ..< 4,
                text: "B"
            )
        ])
        #expect(fragment.line.caretStops.map(\.sourcePoint) == [
            .block(blockID: blockID, utf16Offset: 0),
            .block(blockID: blockID, utf16Offset: 1),
            .block(blockID: blockID, utf16Offset: 3),
            .block(blockID: blockID, utf16Offset: 4)
        ])
        let glyphSlices = fragment.line.glyphRuns
            .flatMap(\.glyphs).flatMap(\.sourceSlices)
        let firstSource = fragment.line.sourceSlices[0].source
        let secondSource = fragment.line.sourceSlices[1].source
        #expect(glyphSlices.allSatisfy
        {
            $0.source == firstSource || $0.source == secondSource
        })
        #expect(glyphSlices.filter { $0.source == firstSource }
            .map(\.range) == [0 ..< 1, 1 ..< 3])
        #expect(glyphSlices.filter { $0.source == secondSource }
            .map(\.range) == [3 ..< 4])
    }

}
