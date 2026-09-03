import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

extension PresentationTransferTests
{
    @MainActor
    @Test("nested lineage and source anchor transfer independently")
    func lineageAndAnchor() throws
    {
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([
                    .paragraph(SemanticParagraph(runs: [
                        PresentationFixture.run("Lineage")
                    ]))
                ])
            )
        )
        let document = try PresentationFixture.snapshot(raster)
            .presentedDocument
        expectLineage(raster.lineage, equals: document.lineage.raster)
        #expect(raster.sourceAnchor.residentID.blockID
            == document.sourceAnchor.residentID.blockID)
        #expect(raster.sourceAnchor.residentID.blockOrdinal
            == document.sourceAnchor.residentID.blockOrdinal)
        #expect(raster.sourceAnchor.residentID.fragmentOrdinal
            == document.sourceAnchor.residentID.fragmentOrdinal)
        #expect(raster.sourceAnchor.relativeX
            == document.sourceAnchor.relativeX)
        #expect(raster.sourceAnchor.relativeY
            == document.sourceAnchor.relativeY)
        #expect(document.residents.all.filter
        {
            $0.residentID == document.sourceAnchor.residentID
        }.count == 1)
    }
}
