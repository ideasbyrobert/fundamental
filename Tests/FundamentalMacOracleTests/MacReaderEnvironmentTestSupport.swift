import AppKit
import Testing

@testable import FundamentalMacOracle

@MainActor
enum MacReaderEnvironmentTestSupport
{
    static func expectCurrent(
        _ controller: MacReaderWindowController
    ) throws
    {
        let window = try #require(controller.window)
        let screen = try #require(window.screen)
        let display = try #require(MacDisplayIdentity(screen))
        let palette = try #require(MacAppearancePalette(
            native: window.effectiveAppearance,
            display: display,
            increasedContrast: NSWorkspace.shared
                .accessibilityDisplayShouldIncreaseContrast
        ))
        let snapshot = controller.readerView.model.snapshot
        let plane = snapshot.presentedDocument.plane
        #expect(plane.backingScale.bitPattern
            == display.backingScale.bitPattern)
        #expect(plane.colorSpace == display.presentation)
        #expect(plane.appearance == palette.appearance)
        #expect(plane.palette == palette.document)
        #expect(snapshot.lineage.specification.adornmentPalette
            == palette.adornments)
    }
}
