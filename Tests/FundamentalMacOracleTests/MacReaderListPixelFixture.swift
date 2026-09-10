import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle
@testable import FundamentalPresentation

@MainActor
enum MacReaderListPixelFixture
{
    static func snapshot(
        kind: SemanticListKind, count: Int, scale: Double
    ) throws -> PresentationSnapshot
    {
        let document = try MacReaderDocumentFixture.source((0 ..< count).map
        {
            _ in MacReaderListFixture.block(kind, "Source")
        })
        let environment = try #require(MacReaderEnvironment(
            screen: MacOracleTestSurface.screen(),
            appearance: MacOracleTestSurface.appearance(),
            increasedContrast: false
        ))
        let initial = try #require(environment.surface(
            viewportWidth: 500, visibleOriginY: 0, visibleHeight: 120
        ))
        let executor = MacRasterExecutor()
        let preparation = try #require(SummitPresentationPreparation(
            surface: surface(initial, scale: scale, y: 0),
            projection: MacReaderDocumentProjection(document),
            admitting: { executor.admit($0) != nil }
        ))
        let height = preparation.currentSnapshot.presentedDocument.plane
            .documentSize.height
        let lease = try #require(preparation.reserveAttempt())
        let attempt = try #require(preparation.prepare(
            surface: surface(initial, scale: scale, y: max(0, height - 120)),
            intent: .document, lease: lease
        ))
        #expect(executor.admit(attempt.snapshot) != nil)
        return attempt.snapshot
    }
}
