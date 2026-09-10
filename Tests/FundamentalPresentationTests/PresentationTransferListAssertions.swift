import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func expectListItem(
        _ source: RasterInteractionRole, equals result: PresentationListItem
    )
    {
        switch source
        {
        case let .bulleted(position):
            #expect(result.kind == .bulleted)
            #expect(position.index == result.position.index)
            #expect(position.count == result.position.count)
        case let .numbered(position):
            #expect(result.kind == .numbered)
            #expect(position.index == result.position.index)
            #expect(position.count == result.position.count)
        default:
            Issue.record("Expected a list role")
        }
    }

    func expectMarker(
        _ source: RasterListMarker?, equals result: PresentationListMarker?
    )
    {
        guard let source, let result
        else
        {
            #expect((source == nil) == (result == nil))
            return
        }
        expectMarkerSource(source.source, equals: result.source)
        #expect(source.baseline.x == result.baseline.x)
        #expect(source.baseline.y == result.baseline.y)
        #expect(source.advance == result.advance)
        #expect(rectangleSignature(source.inkBounds)
            == rectangleSignature(result.inkBounds))
    }

    func expectMarkerSource(
        _ source: RasterListMarkerSource,
        equals result: PresentationListMarkerSource
    )
    {
        #expect(source.residentID.blockID == result.residentID.blockID)
        #expect(source.residentID.blockOrdinal
            == result.residentID.blockOrdinal)
        #expect(source.residentID.fragmentOrdinal
            == result.residentID.fragmentOrdinal)
        #expect(source.label == result.label)
        expectListItem(source.role, equals: result.item)
    }

    func expectGlyphSource(
        _ source: RasterGlyphSource, equals result: PresentationGlyphSource
    )
    {
        switch (source, result)
        {
        case let (.text(old), .text(new)):
            expectSlices(old, equals: new)
        case let (.listMarker(old), .listMarker(new)):
            expectMarkerSource(old, equals: new)
        default:
            Issue.record("Glyph source kind changed")
        }
    }
}
