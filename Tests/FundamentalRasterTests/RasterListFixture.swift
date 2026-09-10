import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalRaster

@MainActor
enum RasterListFixture
{
    static func block(
        _ kind: SemanticListKind, _ text: String,
        traits: Set<SemanticInlineTrait> = []
    ) -> SemanticBlock
    {
        .listItem(SemanticListItem(
            kind: kind, runs: [RasterFixture.run(text, traits: traits)]
        ))
    }

    static func lines(_ layout: LayoutSnapshot) -> [LayoutLineFragment]
    {
        layout.fragments.compactMap
        {
            guard case let .lines(value) = $0 else { return nil }
            return value
        }
    }

    static func texts(_ raster: RasterSnapshot) -> [RasterInteractionText]
    {
        raster.interactionMap.regions.compactMap
        {
            guard case let .text(value) = $0.content else { return nil }
            return value
        }
    }

    static func batches(_ raster: RasterSnapshot) -> [RasterGlyphBatch]
    {
        raster.marks.compactMap
        {
            guard case let .glyphs(value) = $0 else { return nil }
            return value
        }
    }

    static func bounds(_ value: LayoutRectangle) throws -> RasterRectangle
    {
        try RasterFixture.rectangle(
            x: value.minX, y: value.minY,
            width: value.size.width, height: value.size.height
        )
    }

    static func point(_ value: LayoutPoint) throws -> RasterPoint
    {
        try #require(RasterPoint(x: value.x, y: value.y))
    }
}
