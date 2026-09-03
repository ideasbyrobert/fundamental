import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacReaderWindowTests
{
    @Test("light and dark native appearances resolve distinct palettes")
    func appearancesResolveDistinctPalettes() throws
    {
        let light = try MacOracleTestSurface.model(
            appearanceName: .aqua
        ).snapshot.presentedDocument.plane.palette
        let dark = try MacOracleTestSurface.model(
            appearanceName: .darkAqua
        ).snapshot.presentedDocument.plane.palette
        #expect(light.documentBackground != dark.documentBackground)
        #expect(light.text != dark.text)
    }

    @Test("screen and backing notifications preserve a complete surface")
    func displayNotificationsPreserveSurface() throws
    {
        let controller = try MacOracleTestSurface.window()
        let before = controller.readerView.model.snapshot
        let notification = Notification(
            name: NSWindow.didChangeScreenNotification
        )
        controller.windowDidChangeScreen(notification)
        controller.windowDidChangeBackingProperties(notification)
        #expect(controller.readerView.model.snapshot.lineage.generation
            > before.lineage.generation)
        controller.window?.close()
    }

    @Test("a real wide window follows dark effective appearance")
    func wideWindowFollowsDarkAppearance() throws
    {
        let controller = try MacOracleTestSurface.window(width: 1_200)
        let window = try #require(controller.window)
        window.appearance = try MacOracleTestSurface.appearance(.darkAqua)
        controller.showWindow(nil)
        controller.synchronize()
        #expect(window.effectiveAppearance.bestMatch(
            from: [.aqua, .darkAqua]
        ) == .darkAqua)
        #expect(MacRasterExecutor().admits(
            controller.readerView.model.snapshot
        ))
        #expect(controller.readerView.model.readableMeasure == 720)
        window.close()
    }
}
