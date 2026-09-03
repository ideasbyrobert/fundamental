import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalRaster

@Suite("Raster overscan reuse")
struct RasterOverscanTests
{
    @MainActor
    @Test("visible and both overscan directions are exact bounded residents")
    func directionalResidents() throws
    {
        let text = String(
            repeating: "visible overscan resident evidence ",
            count: 30
        )
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            RasterFixture.run(text)
        ]))
        let layout = try RasterFixture.layout([block], width: 120)
        let fragments = layout.fragments
        let target = fragments[3]
        let preceding = target.frame.minY - fragments[2].frame.minY
        let following = fragments[4].frame.maxY - target.frame.maxY
        let viewport = try RasterFixture.viewport(
            layout,
            y: target.frame.minY,
            height: target.frame.size.height,
            preceding: preceding,
            following: following,
            limit: 3
        )
        let raster = try RasterFixture.snapshot(viewport)
        let regions = raster.interactionMap.regions
        #expect(regions.map(\.residence).contains(.visible))
        #expect(regions.map(\.residence)
            .contains(.overscan(.preceding)))
        #expect(regions.map(\.residence)
            .contains(.overscan(.following)))
        let residentIDs = Set(regions.map(\.residentID))
        let nonresident = id(fragments[0])
        #expect(!residentIDs.contains(nonresident))
        #expect(raster.marks.allSatisfy
        {
            residentIDs.contains($0.residentID)
        })
    }

    @MainActor
    @Test("an overscan glyph batch is reusable when its resident is visible")
    func stableMark() throws
    {
        let text = String(repeating: "reuse line ", count: 40)
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            RasterFixture.run(text)
        ]))
        let layout = try RasterFixture.layout([block], width: 120)
        let visible = layout.fragments[3]
        let preceding = layout.fragments[2]
        let first = try RasterFixture.viewport(
            layout,
            y: visible.frame.minY,
            height: visible.frame.size.height,
            preceding: visible.frame.minY - preceding.frame.minY,
            limit: 2
        )
        let second = try RasterFixture.viewport(
            layout,
            y: preceding.frame.minY,
            height: preceding.frame.size.height,
            generation: 14
        )
        let firstRaster = try RasterFixture.snapshot(first)
        let secondRaster = try RasterFixture.snapshot(second)
        let residentID = id(preceding)
        #expect(firstRaster.interactionMap.regions.first
        {
            $0.residentID == residentID
        }?.residence == .overscan(.preceding))
        #expect(secondRaster.interactionMap.regions.first
        {
            $0.residentID == residentID
        }?.residence == .visible)
        #expect(firstRaster.marks.filter { $0.residentID == residentID }
            == secondRaster.marks.filter { $0.residentID == residentID })
    }

    private func id(_ fragment: LayoutFragment) -> RasterResidentID
    {
        RasterResidentID(
            blockID: fragment.anchor.blockID,
            blockOrdinal: fragment.anchor.blockOrdinal,
            fragmentOrdinal: fragment.anchor.fragmentOrdinal
        )
    }
}
