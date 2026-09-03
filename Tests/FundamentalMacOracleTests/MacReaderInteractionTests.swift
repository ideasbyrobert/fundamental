import AppKit
import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

@Suite("The native macOS summit interaction", .serialized)
@MainActor
struct MacReaderInteractionTests
{
    @Test("a native mouse event places the carried caret")
    func nativeMousePlacesCaret() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        controller.showWindow(nil)
        controller.synchronize()
        let view = controller.readerView
        let (resident, line) = try Self.line(in: view.model.snapshot)
        let site = try #require(line.caretSites.dropFirst().first)
        let event = try Self.event(
            type: .leftMouseDown,
            site: site,
            view: view,
            window: window
        )
        view.mouseDown(with: event)
        guard case let .caret(_, caret) = view.model.snapshot
        else
        {
            Issue.record("The caret was not published")
            return
        }
        #expect(caret.position == PresentationTextPosition(
            residentID: resident.residentID,
            sourcePoint: site.sourcePoint
        ))
        window.close()
    }
}
