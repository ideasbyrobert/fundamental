import AppKit
import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

@Suite("Native synchronization event sequences", .serialized)
@MainActor
struct MacSynchronizationSequenceTests
{
    @Test(
        "native caret pixels survive unchanged narrow and wide synchronization",
        arguments: [820.0, 1_200.0], [false, true]
    )
    func caret(width: Double, dark: Bool) throws
    {
        let controller = try MacOracleTestSurface.window(width: width)
        let window = try #require(controller.window)
        defer { window.close() }
        window.appearance = try MacOracleTestSurface.appearance(
            dark ? .darkAqua : .aqua
        )
        controller.showWindow(nil)
        let view = controller.readerView
        let plain = try #require(MacBitmapSurface(view.model.snapshot))
        plain.draw(view.model.rasterExecution)
        let (resident, line) = try MacReaderInteractionTests.line(
            in: view.model.snapshot
        )
        let site = try #require(line.caretSites.dropFirst().first)
        view.mouseDown(with: try MacReaderInteractionTests.event(
            type: .leftMouseDown,
            site: site,
            view: view,
            window: window
        ))
        guard case let .caret(_, caret) = view.model.snapshot
        else
        {
            Issue.record("The native event did not publish a caret")
            return
        }
        #expect(caret.position == PresentationTextPosition(
            residentID: resident.residentID,
            sourcePoint: site.sourcePoint
        ))
        let before = try MacSynchronizationObservation(controller)
        let bitmap = try #require(MacBitmapSurface(before.snapshot))
        bitmap.draw(before.execution)
        let caretBounds = try #require(PresentationPixelBounds(
            logicalBounds: caret.logicalBounds,
            backingScale: before.snapshot.presentedDocument.plane.backingScale
        ))
        #expect(!plain.changedPixels(
            from: bitmap,
            in: caretBounds
        ).isEmpty)
        for _ in 0 ..< 3
        {
            #expect(view.synchronizeFromScrollView())
            try MacAccessibilityGeometryTestSupport.expectSettled(controller)
        }
        #expect(view.model.snapshot == before.snapshot)
        MacReaderRasterPublicationTests.expectSameExecution(
            before.execution,
            view.model.rasterExecution
        )
        let after = try #require(MacBitmapSurface(view.model.snapshot))
        after.draw(view.model.rasterExecution)
        #expect(bitmap.containsInk(in: bitmap.pixelBounds))
        #expect(bitmap.changedPixels(
            from: after,
            in: bitmap.pixelBounds
        ).isEmpty)
        try MacReaderEnvironmentTestSupport.expectCurrent(controller)
    }
}
