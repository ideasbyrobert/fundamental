@testable import FundamentalLayout
@testable import FundamentalProjection

extension LayoutBlockMeasurementTests
{
    func readmit(
        _ value: LayoutBlockMeasurement,
        source: ProjectedBlockSource,
        kind: LayoutBlockMeasurementKind,
        firstExtent: LayoutFragmentExtent,
        remainingExtents: [LayoutFragmentExtent],
        contentFonts: [LayoutFontIdentity]
    ) -> LayoutBlockMeasurement?
    {
        LayoutBlockMeasurement(
            source: source,
            parameters: value.parameters,
            kind: kind,
            firstExtent: firstExtent,
            remainingExtents: remainingExtents,
            contentFonts: contentFonts
        )
    }

    func extent(
        _ value: LayoutFragmentExtent,
        anchor: LayoutFragmentAnchor,
        frame: LayoutRectangle
    ) -> LayoutFragmentExtent
    {
        LayoutFragmentExtent(
            source: value.source,
            anchor: anchor,
            frame: frame,
            content: value.content
        )
    }
}
