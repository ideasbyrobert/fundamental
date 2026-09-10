import Testing

@testable import FundamentalDocument
@testable import FundamentalRaster

extension RasterListTransportTests
{
    @Test("missing misplaced and foreign markers fail before publication",
          arguments: SemanticListKind.allCases)
    func markerOwnership(kind: SemanticListKind) throws
    {
        let layout = try RasterFixture.layout([
            RasterListFixture.block(kind, "Source")
        ])
        let raster = try RasterFixture.snapshot(RasterFixture.viewport(layout))
        let fragment = try #require(RasterListFixture.lines(layout).first)
        let region = raster.interactionMap.firstRegion
        let line = fragment.line
        let specification = raster.lineage.specification
        let position = try #require(RasterListPosition(index: 0, count: 1))
        let next = try #require(RasterListPosition(index: 1, count: 2))
        let wrongCount = try #require(RasterListPosition(index: 0, count: 2))
        let opposite: RasterInteractionRole = kind == .numbered
            ? .bulleted(position) : .numbered(position)
        let wrongPositions = [next, wrongCount].map
        {
            kind == .numbered
                ? RasterInteractionRole.numbered($0) : .bulleted($0)
        }
        for role in [RasterInteractionRole.body, opposite] + wrongPositions
        {
            try RasterListFixture.expectRefusal(
                line, owner: region.residentID, role: role,
                specification: specification
            )
        }
        try RasterListFixture.expectRefusal(
            RasterListFixture.line(line, marker: nil),
            owner: region.residentID, role: region.role,
            specification: specification
        )
        for owner in [
            RasterResidentID(
                blockID: RasterFixture.documentID,
                blockOrdinal: 0, fragmentOrdinal: 0
            ),
            RasterResidentID(
                blockID: region.residentID.blockID,
                blockOrdinal: 1, fragmentOrdinal: 0
            ),
            RasterResidentID(
                blockID: region.residentID.blockID,
                blockOrdinal: 0, fragmentOrdinal: 1
            )
        ]
        {
            try RasterListFixture.expectRefusal(
                line, owner: owner, role: region.role,
                specification: specification
            )
        }
    }

    @Test("generated glyphs cannot impersonate source or decorations")
    func forgedSource() throws
    {
        let layout = try RasterFixture.layout([
            RasterListFixture.block(.numbered, "Source", traits: [.underline])
        ])
        let raster = try RasterFixture.snapshot(RasterFixture.viewport(layout))
        let fragment = try #require(RasterListFixture.lines(layout).first)
        let native = try #require(fragment.line.marker)
        let run = native.firstGlyphRun
        let region = raster.interactionMap.firstRegion
        let slices = fragment.line.sourceSlices
        let decorations = fragment.line.glyphRuns.flatMap(\.decorations)
        #expect(!slices.isEmpty && !decorations.isEmpty)
        for forged in [
            RasterListFixture.run(run, slices: slices),
            RasterListFixture.run(run, glyphSlices: slices),
            RasterListFixture.run(run, decorations: decorations)
        ]
        {
            let marker = RasterListFixture.marker(native, run: forged)
            try RasterListFixture.expectRefusal(
                RasterListFixture.line(fragment.line, marker: marker),
                owner: region.residentID, role: region.role,
                specification: raster.lineage.specification
            )
        }
    }
}
