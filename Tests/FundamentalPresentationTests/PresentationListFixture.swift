import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation
@testable import FundamentalRaster

@MainActor
enum PresentationListFixture
{
    static func raster(
        _ kind: SemanticListKind, text: String = "Readable source",
        count: Int = 1, width: Double = 500
    ) throws -> RasterSnapshot
    {
        let blocks = (0 ..< count).map
        {
            _ in SemanticBlock.listItem(SemanticListItem(
                kind: kind, runs: [PresentationFixture.run(text)]
            ))
        }
        return try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout(blocks, width: width)
            ), scale: 1
        )
    }

    static func expectTransfer(
        _ raster: RasterSnapshot, _ snapshot: PresentationSnapshot
    ) throws
    {
        let document = snapshot.presentedDocument
        let checks = PresentationTransferTests()
        #expect(document.residents.all.count
            == raster.interactionMap.regions.count)
        for (old, new) in zip(
            raster.interactionMap.regions, document.residents.all
        )
        {
            checks.expectRegion(old, equals: new)
        }
        #expect(document.marks.count == raster.marks.count)
        for (old, new) in zip(raster.marks, document.marks)
        {
            switch (old, new)
            {
            case let (.glyphs(source), .glyphs(result)):
                checks.expectBatch(source, equals: result)
            case let (.fill(source), .fill(result)):
                checks.expectFill(source, equals: result)
            default:
                Issue.record("Mark order or kind changed")
            }
        }
        #expect(document.lineage.raster
            == PresentationComposer().rasterLineage(of: raster))
    }
}
