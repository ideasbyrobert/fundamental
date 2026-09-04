import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutBlockMeasurementTests
{
    @MainActor
    func expectTableRefusal() throws
    {
        let value = try product(
            .table(try LayoutFixture.table(captioned: false)),
            width: 360
        ).measurement
        let facts = try #require(tableFacts(value))
        let wrong = try #require(LayoutTableMeasurement(
            rowCount: facts.rowCount + 1,
            cellCount: facts.cellCount,
            structuralFont: facts.structuralFont
        ))
        #expect(readmit(
            value,
            source: value.source,
            kind: .table(wrong),
            firstExtent: value.firstExtent,
            remainingExtents: value.remainingExtents,
            contentFonts: value.contentFonts
        ) == nil)
        #expect(LayoutTableMeasurement(
            rowCount: -1,
            cellCount: 0,
            structuralFont: facts.structuralFont
        ) == nil)
        #expect(LayoutTableMeasurement(
            rowCount: 0,
            cellCount: -1,
            structuralFont: facts.structuralFont
        ) == nil)
        let second = try #require(value.remainingExtents.first)
        let outsidePoint = try #require(LayoutPoint(
            x: 0,
            y: value.firstExtent.frame.maxY
        ))
        let outsideFrame = try #require(LayoutRectangle(
            origin: outsidePoint,
            size: second.frame.size
        ))
        let outside = extent(
            second,
            anchor: second.anchor,
            frame: outsideFrame
        )
        #expect(readmit(
            value,
            source: value.source,
            kind: value.kind,
            firstExtent: value.firstExtent,
            remainingExtents: [outside]
                + value.remainingExtents.dropFirst(),
            contentFonts: value.contentFonts
        ) == nil)
    }
}
