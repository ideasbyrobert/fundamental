import Testing

@testable import FundamentalRaster

extension PresentationListFixture
{
    static func corrupt(
        _ raster: RasterSnapshot, fault: PresentationListFault
    ) throws -> RasterSnapshot
    {
        var regions = raster.interactionMap.regions
        let first = try #require(regions.first)
        guard case let .text(line) = first.content
        else
        {
            throw PresentationListTestFailure.missingText
        }
        let marker = try #require(line.marker)
        var marks = raster.marks
        let inkIndex = try #require(marks.firstIndex
        {
            guard case let .glyphs(batch) = $0,
                  case .listMarker = batch.source
            else { return false }
            return true
        })
        switch fault
        {
        case .missingMarker:
            regions[0] = try region(first, marker: nil)
        case .missingGlyphs:
            marks.remove(at: inkIndex)
        case .ordinaryRole:
            regions[0] = try region(first, role: .body, marker: marker)
        case .wrongKind, .wrongIndex, .wrongCount, .foreignOwner:
            let position = try #require(RasterListPosition(
                index: fault == .wrongIndex ? 1 : 0,
                count: fault == .wrongCount ? 3 : 2
            ))
            let role: RasterInteractionRole = fault == .wrongKind
                ? .bulleted(position) : .numbered(position)
            let owner = fault == .foreignOwner
                ? regions[1].residentID : first.residentID
            let source = try #require(RasterListMarkerSource(
                residentID: owner, role: role
            ))
            let changed = try #require(RasterListMarker(
                source: source, baseline: marker.baseline,
                advance: marker.advance, inkBounds: marker.inkBounds
            ))
            regions[0] = try region(first, marker: changed)
        case .foreignGlyphSource, .canonicalMarkerGlyph:
            guard case let .glyphs(ink) = marks[inkIndex]
            else { throw PresentationListTestFailure.missingText }
            let source = try #require(RasterListMarkerSource(
                residentID: regions[1].residentID, role: first.role
            ))
            let slices = fault == .canonicalMarkerGlyph
                ? line.sourceSlices : nil
            marks[inkIndex] = .glyphs(batch(
                ink,
                source: fault == .foreignGlyphSource
                    ? .listMarker(source) : ink.source,
                glyphSlices: slices
            ))
        }
        return try replacing(raster, regions: regions, marks: marks)
    }
}
