import AppKit
import Testing

@testable import FundamentalMacOracle

@Suite("The macOS summit architecture")
@MainActor
struct MacOracleArchitectureTests
{
    @Test("the summit produces one presentation snapshot")
    func summitProducesSnapshot() throws
    {
        let screen = try #require(NSScreen.main)
        let appearance = try #require(NSAppearance(named: .aqua))
        let model = try #require(MacReaderModel(
            viewportWidth: 820,
            viewportHeight: 680,
            screen: screen,
            appearance: appearance
        ))
        #expect(model.documentWidth == 720)
        #expect(model.documentHeight > 680)
        #expect(model.layoutExecutionCount == 1)
    }
}
