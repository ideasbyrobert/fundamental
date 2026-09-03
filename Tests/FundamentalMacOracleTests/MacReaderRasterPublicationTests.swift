import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

@Suite("The native reader raster publication")
@MainActor
struct MacReaderRasterPublicationTests
{
    @Test("stale work preserves the published snapshot and execution")
    func staleWorkPreservesPublication() throws
    {
        let model = try MacOracleTestSurface.model()
        let (preparation, surface) = try MacOracleTestPreparation.make()
        let staleLease = try #require(preparation.reserveAttempt())
        let stale = try #require(preparation.prepare(
            surface: surface,
            intent: .document,
            lease: staleLease
        ))
        let (first, last) = try Self.positions(in: model)
        #expect(model.showCaret(at: first))
        #expect(model.showSelection(anchor: first, focus: last))
        let snapshot = model.snapshot
        let execution = model.rasterExecution
        #expect(stale.lease.generation < snapshot.lineage.generation)
        #expect(!model.publish(stale))
        #expect(model.snapshot == snapshot)
        Self.expectSameExecution(execution, model.rasterExecution)
    }

    @Test("native refusal preserves the published snapshot and execution")
    func nativeRefusalPreservesPublication() throws
    {
        let model = try MacOracleTestSurface.model()
        let (first, last) = try Self.positions(in: model)
        #expect(model.showCaret(at: first))
        let (preparation, surface) = try MacOracleTestPreparation.make()
        let lease = try #require(preparation.reserveAttempt())
        let attempt = try #require(preparation.prepare(
            surface: surface,
            intent: .caret(first),
            lease: lease
        ))
        let color = try #require(
            MacRasterSnapshotFixture.mismatchedColor(in: attempt.snapshot)
        )
        let poisoned = try #require(
            MacRasterSnapshotFixture.replacingCaretColor(
                in: attempt.snapshot,
                with: color
            )
        )
        let refused = SummitPresentationAttempt(
            snapshot: poisoned,
            lease: attempt.lease,
            raster: attempt.raster,
            surface: attempt.surface
        )
        let snapshot = model.snapshot
        let execution = model.rasterExecution
        #expect(refused.lease.generation == snapshot.lineage.generation)
        #expect(MacRasterExecutor().admit(poisoned) == nil)
        #expect(!model.publish(refused))
        #expect(model.snapshot == snapshot)
        Self.expectSameExecution(execution, model.rasterExecution)
        #expect(model.showSelection(anchor: first, focus: last))
        #expect(model.rasterExecution.documentExecution
            === execution.documentExecution)
    }
}
