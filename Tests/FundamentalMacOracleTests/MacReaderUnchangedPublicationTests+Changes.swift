import Testing

@testable import FundamentalMacOracle

extension MacReaderUnchangedPublicationTests
{
    @Test("genuine surface changes still publish once per model update")
    func changedSurface() throws
    {
        let model = try MacOracleTestSurface.model()
        let (first, _) = try MacReaderRasterPublicationTests.positions(
            in: model
        )
        #expect(model.showCaret(at: first))
        let before = model.snapshot
        let layouts = model.layoutExecutionCount
        #expect(try Self.update(model, width: 600))
        #expect(model.snapshot.lineage.generation
            == before.lineage.generation + 1)
        #expect(model.layoutExecutionCount == layouts + 1)
        #expect(model.readableMeasure == 536)
        #expect(!model.snapshot.presentedDocument.sharesStorage(
            with: before.presentedDocument
        ))
        guard case .document = model.snapshot
        else
        {
            Issue.record("Changed surfaces retain document-only intent")
            return
        }
        #expect(try Self.update(model, width: 600, height: 720))
        #expect(model.snapshot.lineage.generation
            == before.lineage.generation + 2)
        #expect(try Self.update(
            model,
            width: 600,
            height: 720,
            origin: 24
        ))
        #expect(model.snapshot.lineage.generation
            == before.lineage.generation + 3)
        #expect(model.visibleOriginY == 24)
        #expect(model.layoutExecutionCount == layouts + 1)
    }
}
