import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    @MainActor
    @Test("global glyph and fill order survives without paint-order sorting")
    func globalMarkOrder() throws
    {
        let blocks = [
            SemanticBlock.paragraph(SemanticParagraph(runs: [
                PresentationFixture.run("First"),
                PresentationFixture.run(
                    " underlined",
                    traits: [.underline]
                )
            ])),
            .paragraph(SemanticParagraph(runs: [
                PresentationFixture.run("Second")
            ]))
        ]
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout(blocks, width: 500)
            )
        )
        let document = try PresentationFixture.snapshot(raster)
            .presentedDocument
        #expect(raster.marks.map(rasterMarkSignature)
            == document.marks.map(presentationMarkSignature))
        let orders: [Int] = document.marks.compactMap
        {
            guard case let .glyphs(batch) = $0
            else
            {
                return nil
            }
            return batch.paintOrder
        }
        #expect(orders == [0, 1, 0])
    }

    private func rasterMarkSignature(_ mark: RasterMark) -> String
    {
        switch mark
        {
        case let .glyphs(batch):
            return "g:\(batch.paintOrder):"
                + batch.glyphs.map
                {
                    String($0.identifier)
                }.joined()
        case let .fill(fill):
            let bounds = fill.logicalBounds
            return "f:\(fill.role):\(bounds.minX):\(bounds.minY):"
                + "\(bounds.size.width):\(bounds.size.height)"
        }
    }

    private func presentationMarkSignature(
        _ mark: PresentationMark
    ) -> String
    {
        switch mark
        {
        case let .glyphs(batch):
            return "g:\(batch.paintOrder):"
                + batch.glyphs.map
                {
                    String($0.identifier)
                }.joined()
        case let .fill(fill):
            let bounds = fill.logicalBounds
            return "f:\(fill.role):\(bounds.minX):\(bounds.minY):"
                + "\(bounds.size.width):\(bounds.size.height)"
        }
    }
}
