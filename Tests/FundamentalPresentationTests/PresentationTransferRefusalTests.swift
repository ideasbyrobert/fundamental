import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    @MainActor
    @Test("a mismatched resident role and content refuses atomically")
    func mismatchedRole() throws
    {
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([
                    .paragraph(SemanticParagraph(runs: [
                        PresentationFixture.run("Body")
                    ]))
                ])
            )
        )
        let first = raster.interactionMap.firstRegion
        let poisoned = RasterInteractionRegion(
            residentID: first.residentID,
            residence: first.residence,
            role: .table,
            frame: first.frame,
            content: first.content
        )
        let input = RasterSnapshot(
            lineage: raster.lineage,
            documentSize: raster.documentSize,
            sourceAnchor: raster.sourceAnchor,
            marks: raster.marks,
            interactionMap: RasterInteractionMap(
                firstRegion: poisoned,
                remainingRegions: raster.interactionMap.remainingRegions
            )
        )
        let request = try PresentationFixture.request(input)
        #expect(PresentationComposer().present(
            input,
            request: request
        ) == nil)
    }
}
