import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

@Suite("The bounded macOS summit viewport")
@MainActor
struct SummitBoundedScrollTests
{
    @Test("near and far snapshots preserve lineage within fixed bounds")
    func nearAndFarRemainBounded() throws
    {
        let model = try MacOracleTestSurface.model()
        let screen = try MacOracleTestSurface.screen()
        let appearance = try MacOracleTestSurface.appearance()
        let near = model.snapshot.presentedDocument
        #expect(model.update(
            viewportWidth: 820,
            viewportHeight: 680,
            visibleOriginY: model.documentHeight,
            screen: screen,
            appearance: appearance
        ))
        let far = model.snapshot.presentedDocument
        #expect(near.sourceAnchor != far.sourceAnchor)
        #expect(near.lineage.raster.viewport.layout.document
            == far.lineage.raster.viewport.layout.document)
        #expect(near.lineage.raster.viewport.layout.generation
            == far.lineage.raster.viewport.layout.generation)
        expectBounds(near)
        expectBounds(far)
    }

    @Test("repeated residence keeps an exact stable source anchor")
    func repeatedResidenceKeepsAnchor() throws
    {
        let model = try MacOracleTestSurface.model()
        let screen = try MacOracleTestSurface.screen()
        let appearance = try MacOracleTestSurface.appearance()
        #expect(model.update(
            viewportWidth: 820,
            viewportHeight: 680,
            visibleOriginY: 1_000,
            screen: screen,
            appearance: appearance
        ))
        let first = model.snapshot.presentedDocument.sourceAnchor
        #expect(model.update(
            viewportWidth: 820,
            viewportHeight: 680,
            visibleOriginY: 1_000,
            screen: screen,
            appearance: appearance
        ))
        #expect(model.snapshot.presentedDocument.sourceAnchor == first)
    }

    private func expectBounds(_ document: PresentedDocument)
    {
        let residents = document.residents.all
        let glyphCount = document.marks.reduce(0)
        {
            count, mark in
            guard case let .glyphs(batch) = mark
            else
            {
                return count
            }
            return count + batch.glyphs.count
        }
        let caretCount = residents.reduce(0)
        {
            $0 + Self.caretCount($1.content)
        }
        #expect(residents.count <= 192)
        #expect(document.marks.count <= 100_000)
        #expect(glyphCount <= 100_000)
        #expect(caretCount <= 100_000)
    }
}
