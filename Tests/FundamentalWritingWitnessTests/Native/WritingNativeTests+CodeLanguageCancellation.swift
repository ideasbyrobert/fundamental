import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test
    func codeLanguageIsContextualAndCancellationRetainsEditorState()
        async throws
    {
        let fixture = try WritingCodeFixture.document("A", tagged: true)
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        let control = window.controller.formatting.block
        let item = try #require(control.itemArray.first
            { $0.identifier == WritingCodeLanguageMenu.identifier })
        #expect(item.isHidden)
        let width = control.frame.width
        window.select(7, 1)
        #expect(!item.isHidden && window.controller.canChooseCodeLanguage)
        let before = window.storage
        let sheet = try window.openLanguageSheet()
        #expect(sheet.alert.window.sheetParent ===
            window.controller.documentWindow)
        #expect(sheet.field.stringValue == WritingCodeFixture.language)
        #expect(!window.controller.canFormatSelection)
        #expect(!window.controller.mayClose())
        let save = NSMenuItem(title: "Save",
            action: #selector(WritingWindowController.saveDocument(_:)),
            keyEquivalent: "s")
        #expect(!window.controller.validateUserInterfaceItem(save))
        window.setLanguage("Cancelled", in: sheet)
        try await window.finishLanguageSheet(sheet,
                                             response: .alertSecondButtonReturn)
        #expect(window.storage == before)
        #expect(window.view.selectedRange() == NSRange(location: 7, length: 1))
        #expect(window.controller.documentWindow.firstResponder === window.view)
        #expect(control.selectedItem?.title == "Code")
        #expect(control.frame.width == width)
        window.select(0)
        #expect(item.isHidden && !window.controller.canChooseCodeLanguage)
        let menu = try #require(WritingApplicationMenu.formatMenu()
            .item(withTitle: "Paragraph Style")?.submenu)
        WritingFormattingMenuDelegate.shared.menuNeedsUpdate(menu)
        #expect(menu.item(withTitle: WritingCodeLanguageMenu.title)?.isHidden ==
            true)
    }
}
