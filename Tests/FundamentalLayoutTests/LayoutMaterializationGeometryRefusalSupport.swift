import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    func expectReconstructedGeometryRefusal() throws
    {
        let value = try product([
            .paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct("Short")
            ]))
        ], width: 140)
        let alternate = try LayoutFixture.projection([
            longParagraph("Different reconstructed geometry")
        ])
        let layout = NativeTextKit2Layout()
        let laid = try layout.blockLayout(
            alternate.firstBlock,
            originY: 0,
            parameters: value.request.parameters
        )
        let range = try #require(value.index.completeExtentRange(
            containing: value.index.extents[0]
        ))
        #expect(!layout.reconstructedBlockMatches(
            laid.fragments,
            extents: value.index.extents[range]
        ))
        #expect(layout.projectedBlock(
            at: 1,
            in: value.projection
        ) == nil)
    }
}
