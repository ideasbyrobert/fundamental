import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

@Suite("Presentation transfer")
struct PresentationTransferTests
{
    @MainActor
    @Test("the document plane lineage and global mark order remain exact")
    func documentPlane() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            PresentationFixture.run(
                "A e\u{301} 👨‍👩‍👧‍👦",
                traits: [.underline]
            )
        ]))
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([block], width: 500)
            )
        )
        let snapshot = try PresentationFixture.snapshot(raster)
        guard case let .document(document) = snapshot
        else
        {
            Issue.record("Expected a document presentation")
            return
        }
        let rasterLineage = try #require(
            PresentationComposer().rasterLineage(of: raster)
        )
        #expect(document.lineage.raster == rasterLineage)
        #expect(document.plane.documentSize.width
            == raster.documentSize.width)
        #expect(document.plane.logicalBounds.minY
            == raster.lineage.specification.logicalBounds.minY)
        #expect(document.plane.pixelBounds.area
            == raster.lineage.specification.pixelBounds.area)
        #expect(document.plane.colorSpace.profile
            == raster.lineage.specification.colorSpace.profile)
        let expectedIDs = try raster.marks.map
        {
            try #require(PresentationResidentID(
                    blockID: $0.residentID.blockID,
                    blockOrdinal: $0.residentID.blockOrdinal,
                    fragmentOrdinal: $0.residentID.fragmentOrdinal
            ))
        }
        #expect(document.marks.map(\.residentID) == expectedIDs)
    }
}
