import Testing

@testable import FundamentalLayout

extension LayoutBlockMeasurementTests
{
    func expectGeometryRefusal(
        _ value: LayoutBlockMeasurement
    ) throws
    {
        let first = value.firstExtent
        let translatedPoint = try #require(LayoutPoint(x: 1, y: 0))
        let translatedFrame = try #require(LayoutRectangle(
            origin: translatedPoint,
            size: first.frame.size
        ))
        let translated = extent(
            first,
            anchor: first.anchor,
            frame: translatedFrame
        )
        #expect(readmit(
            value,
            source: value.source,
            kind: value.kind,
            firstExtent: translated,
            remainingExtents: value.remainingExtents,
            contentFonts: value.contentFonts
        ) == nil)
        let second = try #require(value.remainingExtents.first)
        let negativePoint = try #require(LayoutPoint(x: 0, y: -1))
        let negativeFrame = try #require(LayoutRectangle(
            origin: negativePoint,
            size: second.frame.size
        ))
        let negative = extent(
            second,
            anchor: second.anchor,
            frame: negativeFrame
        )
        #expect(readmit(
            value,
            source: value.source,
            kind: value.kind,
            firstExtent: value.firstExtent,
            remainingExtents: [negative]
                + value.remainingExtents.dropFirst(),
            contentFonts: value.contentFonts
        ) == nil)
    }
}
