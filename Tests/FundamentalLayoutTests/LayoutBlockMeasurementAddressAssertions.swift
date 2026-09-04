import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutBlockMeasurementTests
{
    func expectAddressRefusal(
        _ value: LayoutBlockMeasurement,
        block: SemanticBlock
    ) throws
    {
        let projection = try LayoutFixture.projection([block, block])
        let foreign = projection.blocks[1].source
        #expect(readmit(
            value,
            source: foreign,
            kind: value.kind,
            firstExtent: value.firstExtent,
            remainingExtents: value.remainingExtents,
            contentFonts: value.contentFonts
        ) == nil)
        let foreignAnchor = LayoutFragmentAnchor(
            source: foreign,
            fragmentOrdinal: 0
        )
        let foreignExtent = extent(
            value.firstExtent,
            anchor: foreignAnchor,
            frame: value.firstExtent.frame
        )
        #expect(readmit(
            value,
            source: value.source,
            kind: value.kind,
            firstExtent: foreignExtent,
            remainingExtents: value.remainingExtents,
            contentFonts: value.contentFonts
        ) == nil)
        let skippedAnchor = LayoutFragmentAnchor(
            source: value.source,
            fragmentOrdinal: 1
        )
        let skipped = extent(
            value.firstExtent,
            anchor: skippedAnchor,
            frame: value.firstExtent.frame
        )
        #expect(readmit(
            value,
            source: value.source,
            kind: value.kind,
            firstExtent: skipped,
            remainingExtents: value.remainingExtents,
            contentFonts: value.contentFonts
        ) == nil)
        let second = try #require(value.remainingExtents.first)
        let duplicateAnchor = LayoutFragmentAnchor(
            source: value.source,
            fragmentOrdinal: 0
        )
        let duplicate = extent(
            second,
            anchor: duplicateAnchor,
            frame: second.frame
        )
        #expect(readmit(
            value,
            source: value.source,
            kind: value.kind,
            firstExtent: value.firstExtent,
            remainingExtents: [duplicate]
                + value.remainingExtents.dropFirst(),
            contentFonts: value.contentFonts
        ) == nil)
    }
}
