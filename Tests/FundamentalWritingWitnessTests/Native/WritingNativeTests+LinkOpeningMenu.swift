import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("linked text exposes deliberate owned opening commands")
    func linkOpeningMenuAdmission() throws
    {
        let run = try WritingScopeFixture.run("Linked text", form: 0)
        let source = try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [run]))
        ])
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state
        ))
        defer
        {
            window.close()
        }
        let before = window.storage
        let selection = window.controller.bridge.projection.snapshot.selection
        window.view.layoutSubtreeIfNeeded()
        window.controller.documentWindow.displayIfNeeded()
        let rect = window.view.firstRect(forCharacterRange: NSRange(
            location: 1, length: 1
        ), actualRange: nil)
        #expect(rect.width > 0 && rect.height > 0)
        let point = window.controller.documentWindow.convertPoint(fromScreen:
            NSPoint(x: rect.midX, y: rect.midY))
        let event = try #require(NSEvent.mouseEvent(with: .rightMouseDown,
            location: point, modifierFlags: [], timestamp: 1,
            windowNumber: window.controller.documentWindow.windowNumber,
            context: nil, eventNumber: 0, clickCount: 1, pressure: 1))
        let menu = try #require(window.view.menu(for: event))
        #expect(window.view.selectedRange() == NSRange(location: 0, length: 11))
        #expect(window.controller.bridge.projection.snapshot.selection !=
            selection)
        let open = try #require(menu.item(withTitle: "Open Link"))
        #expect(open.action == #selector(WritingWindowController.openLink(_:)))
        #expect(window.controller.validateUserInterfaceItem(open))
        let format = try #require(menu.item(withTitle: "Format")?.submenu)
        #expect(format.items.map(\.title) ==
            ["Paragraph Style", "Text Style", "List"])
        #expect(menu.items.filter { $0.title == "Open Link" }.count == 1)
        #expect(menu.item(withTitle: "Font") == nil)
        #expect(menu.item(withTitle: "Substitutions") == nil)
        #expect(window.session.document == before.state.snapshot.document)
        #expect(window.session.history == before.history)
        #expect(window.view.textLayoutManager != nil)
        let text = try #require(WritingInlineMenu.menuItem().submenu)
        #expect(text.items.contains
        {
            $0.identifier?.rawValue == "FundamentalOpenLink"
        })
    }
}
