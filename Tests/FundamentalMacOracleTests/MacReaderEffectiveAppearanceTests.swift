import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacReaderWindowTests
{
    @Test("a real wide window publishes its changed native appearance")
    func wideWindowPublishesChangedAppearance() throws
    {
        let controller = try MacOracleTestSurface.window(width: 1_200)
        let window = try #require(controller.window)
        defer { window.close() }
        window.appearance = try MacOracleTestSurface.appearance(.aqua)
        controller.showWindow(nil)
        let before = controller.readerView.model.snapshot
        let beforePlane = before.presentedDocument.plane
        let layoutExecutions = controller.readerView.model
            .layoutExecutionCount
        window.appearance = try MacOracleTestSurface.appearance(.darkAqua)
        let after = controller.readerView.model.snapshot
        let afterPlane = after.presentedDocument.plane
        try MacReaderEnvironmentTestSupport.expectCurrent(controller)
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
        #expect(after.lineage.generation > before.lineage.generation)
        #expect(afterPlane.appearance != beforePlane.appearance)
        #expect(afterPlane.palette != beforePlane.palette)
        #expect(after.lineage.specification.adornmentPalette
            != before.lineage.specification.adornmentPalette)
        #expect(controller.readerView.model.layoutExecutionCount
            == layoutExecutions)
        #expect(window.effectiveAppearance.bestMatch(
            from: [.aqua, .darkAqua]
        ) == .darkAqua)
        #expect(controller.readerView.model.readableMeasure == 720)
    }
}
