import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacReaderListTests
{
    @Test("clicking generated ink places a source caret",
          arguments: SemanticListKind.allCases, ["", "Source"])
    func markerClicks(kind: SemanticListKind, text: String) throws
    {
        let source = try MacReaderDocumentFixture.source([
            MacReaderListFixture.block(kind, text)
        ])
        let controller = try MacReaderDocumentFixture.window(source)
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        controller.synchronize()
        let view = controller.readerView
        let document = view.model.snapshot.presentedDocument
        let resident = document.residents.first
        let marker = try #require(resident.content.listMarker)
        let local = NSPoint(
            x: marker.inkBounds.minX + marker.inkBounds.size.width / 2
                + view.horizontalInset,
            y: marker.inkBounds.minY + marker.inkBounds.size.height / 2
        )
        let event = try #require(NSEvent.mouseEvent(
            with: .leftMouseDown, location: view.convert(local, to: nil),
            modifierFlags: [], timestamp: 1,
            windowNumber: window.windowNumber, context: nil,
            eventNumber: 1, clickCount: 1, pressure: 1
        ))
        view.mouseDown(with: event)
        guard case let .caret(_, caret) = view.model.snapshot
        else
        {
            Issue.record("A marker click must place a canonical caret")
            return
        }
        #expect(caret.position.residentID == resident.residentID)
        #expect(caret.position.sourcePoint.domain
            == .block(resident.residentID.blockID))
        #expect(caret.position.sourcePoint.utf16Offset == 0)
        #expect(view.model.snapshot.presentedDocument.sharesStorage(
            with: document
        ))
    }
}
