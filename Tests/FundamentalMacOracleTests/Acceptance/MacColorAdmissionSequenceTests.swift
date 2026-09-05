import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

@Suite("Native color refusal preserves publication", .serialized)
@MainActor
struct MacColorAdmissionSequenceTests
{
    @Test(
        "each poisoned color refuses before an eligible valid publication",
        arguments: MacColorPoison.allCases
    )
    func refusalThenPublication(site: MacColorPoison) throws
    {
        let model = try MacOracleTestSurface.model()
        let (first, last) = try MacReaderRasterPublicationTests.positions(
            in: model
        )
        try #require(model.showCaret(at: first))
        let (preparation, surface) = try MacOracleTestPreparation.make()
        let lease = try #require(preparation.reserveAttempt())
        let intent: PresentationIntent
        switch site
        {
        case .caret:
            intent = .caret(first)
        case .selection:
            intent = .selection(try #require(PresentationTextSelection(
                anchor: first,
                focus: last
            )))
        case .background, .fill, .glyph:
            intent = .document
        }
        let attempt = try #require(preparation.prepare(
            surface: surface,
            intent: intent,
            lease: lease
        ))
        let before = model.snapshot
        let execution = model.rasterExecution
        let layouts = model.layoutExecutionCount
        try #require(lease.generation == before.lineage.generation)
        try #require(MacRasterExecutor().admit(attempt.snapshot) != nil)
        let poisoned = try site.applying(to: attempt.snapshot)
        let refused = SummitPresentationAttempt(
            snapshot: poisoned,
            lease: lease,
            raster: attempt.raster,
            surface: surface
        )
        #expect(MacRasterExecutor().admit(poisoned) == nil)
        #expect(!model.publish(refused))
        #expect(model.snapshot == before)
        #expect(model.layoutExecutionCount == layouts)
        MacReaderRasterPublicationTests.expectSameExecution(
            execution,
            model.rasterExecution
        )
        #expect(model.publish(attempt))
        #expect(model.snapshot == attempt.snapshot)
        #expect(model.rasterExecution.lineage == attempt.snapshot.lineage)
    }
}
