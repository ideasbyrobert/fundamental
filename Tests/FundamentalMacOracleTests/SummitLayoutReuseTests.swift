import AppKit
import Testing

@testable import FundamentalMacOracle

@Suite("The macOS summit layout cache")
@MainActor
struct SummitLayoutReuseTests
{
    @Test("equal readable measure preserves one layout execution")
    func equalMeasureReusesLayout() throws
    {
        let model = try MacOracleTestSurface.model()
        let screen = try MacOracleTestSurface.screen()
        let appearance = try MacOracleTestSurface.appearance()
        #expect(model.layoutExecutionCount == 1)
        #expect(model.update(
            viewportWidth: 1_200,
            viewportHeight: 680,
            visibleOriginY: 240,
            screen: screen,
            appearance: appearance
        ))
        #expect(model.readableMeasure == 720)
        #expect(model.layoutExecutionCount == 1)
    }

    @Test("each changed measure replaces the one cached layout")
    func changedMeasureReplacesLayout() throws
    {
        let model = try MacOracleTestSurface.model()
        let screen = try MacOracleTestSurface.screen()
        let appearance = try MacOracleTestSurface.appearance()
        #expect(model.update(
            viewportWidth: 600,
            viewportHeight: 680,
            visibleOriginY: 0,
            screen: screen,
            appearance: appearance
        ))
        #expect(model.readableMeasure == 536)
        #expect(model.layoutExecutionCount == 2)
        #expect(model.update(
            viewportWidth: 600,
            viewportHeight: 480,
            visibleOriginY: 100,
            screen: screen,
            appearance: appearance
        ))
        #expect(model.layoutExecutionCount == 2)
    }
}
