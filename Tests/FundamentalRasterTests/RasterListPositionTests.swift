import Foundation
import Testing

@testable import FundamentalRaster

@Suite("Raster list position and marker identity")
struct RasterListPositionTests
{
    @Test("the final integer position has a finite exact generated label")
    func terminalPosition() throws
    {
        let position = try #require(RasterListPosition(
            index: Int.max - 1, count: Int.max
        ))
        #expect(position.number == Int.max)
        let owner = RasterResidentID(
            blockID: UUID(), blockOrdinal: Int.max, fragmentOrdinal: 0
        )
        let source = try #require(RasterListMarkerSource(
            residentID: owner, role: .numbered(position)
        ))
        #expect(source.position == position)
        #expect(source.label == "\(Int.max).")
        #expect(source.role == .numbered(position))
        #expect(RasterGlyphSource.listMarker(source).sourceSlices.isEmpty)
        #expect(RasterListMarkerSource(
            residentID: owner, role: .body
        ) == nil)
        for ordinal in [-1, 1, Int.max]
        {
            #expect(RasterListMarkerSource(
                residentID: RasterResidentID(
                    blockID: owner.blockID, blockOrdinal: 0,
                    fragmentOrdinal: ordinal
                ), role: .numbered(position)
            ) == nil)
        }
        #expect(RasterListMarkerSource(
            residentID: RasterResidentID(
                blockID: owner.blockID, blockOrdinal: -1, fragmentOrdinal: 0
            ), role: .numbered(position)
        ) == nil)
    }

    @Test("invalid list positions refuse without integer overflow",
          arguments: [
              (-1, 1), (0, 0), (0, -1), (1, 1), (Int.max, Int.max)
          ])
    func invalidPosition(pair: (Int, Int))
    {
        #expect(RasterListPosition(index: pair.0, count: pair.1) == nil)
    }
}
