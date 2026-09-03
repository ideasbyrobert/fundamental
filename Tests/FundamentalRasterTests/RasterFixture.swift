import Testing

@testable import FundamentalRaster
@testable import FundamentalViewport

enum RasterFixture
{
    static func rectangle(
        x: Double,
        y: Double,
        width: Double,
        height: Double
    ) throws -> RasterRectangle
    {
        let origin = try #require(RasterPoint(x: x, y: y))
        let size = try #require(RasterSize(
            width: width,
            height: height
        ))
        return try #require(RasterRectangle(
            origin: origin,
            size: size
        ))
    }

    static func capacities(
        value: Int = 1_000_000
    ) throws -> RasterCapacities
    {
        try #require(RasterCapacities(
            marks: value,
            glyphs: value,
            fills: value,
            sourceSlices: value,
            caretSites: value,
            interactionRegions: value,
            fontVariations: value,
            residentUTF16Units: value,
            pixelArea: value
        ))
    }

    static func colorSpace() throws -> RasterColorSpaceIdentity
    {
        try #require(RasterColorSpaceIdentity(
            name: "Test RGB",
            profile: [1, 2, 3],
            componentCount: 3
        ))
    }

    static func palette() throws -> RasterPalette
    {
        let space = try colorSpace()
        func color(_ value: Double) throws -> RasterColor
        {
            try #require(RasterColor(
                colorSpace: space,
                components: [value, value, value],
                alpha: 1
            ))
        }
        return try #require(RasterPalette(
            documentBackground: color(1),
            tableBackground: color(0.9),
            headerBackground: color(0.8),
            rule: color(0.4),
            text: color(0.1),
            decoration: color(0.2)
        ))
    }

    static func targetBounds(
        _ viewport: ViewportSnapshot
    ) throws -> RasterRectangle
    {
        let specification = viewport.lineage.specification
        let minimumY = max(
            0,
            specification.visibleBounds.minY
                - specification.precedingOverscanExtent
        )
        let maximumY = min(
            viewport.documentSize.height,
            specification.visibleBounds.maxY
                + specification.followingOverscanExtent
        )
        return try rectangle(
            x: 0,
            y: minimumY,
            width: viewport.documentSize.width,
            height: maximumY - minimumY
        )
    }
}
