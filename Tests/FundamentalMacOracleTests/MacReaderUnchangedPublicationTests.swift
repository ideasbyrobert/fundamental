import AppKit
import Testing

@testable import FundamentalMacOracle

@Suite("Unchanged native reader publications", .serialized)
@MainActor
struct MacReaderUnchangedPublicationTests
{
    @Test("equal updates preserve publication without consuming a generation")
    func equalSurface() throws
    {
        let model = try MacOracleTestSurface.model()
        let snapshot = model.snapshot
        let execution = model.rasterExecution
        let layouts = model.layoutExecutionCount
        for _ in 0 ..< 3
        {
            #expect(try Self.update(model))
            #expect(model.snapshot == snapshot)
            MacReaderRasterPublicationTests.expectSameExecution(
                execution,
                model.rasterExecution
            )
            #expect(model.layoutExecutionCount == layouts)
        }
        let (first, _) = try MacReaderRasterPublicationTests.positions(
            in: model
        )
        #expect(model.showCaret(at: first))
        #expect(model.snapshot.lineage.generation
            == snapshot.lineage.generation + 1)
    }

    static func update(
        _ model: MacReaderModel,
        width: Double = 820,
        height: Double = 680,
        origin: Double = 0
    ) throws -> Bool
    {
        model.update(
            viewportWidth: width,
            viewportHeight: height,
            visibleOriginY: origin,
            screen: try MacOracleTestSurface.screen(),
            appearance: try MacOracleTestSurface.appearance()
        )
    }
}
