import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("native controls create each prose role and preserve selection")
    func semanticControls() throws
    {
        let window = try WritingTestWindow("A😀B")
        defer
        {
            window.close()
        }
        window.select(1, 2)
        for style in [CanonicalBlockStyle.title, .heading, .subheading, .body]
        {
            try window.choose(style)
            #expect(window.styles == [style])
            try window.expect("A😀B", selection: NSRange(location: 1, length: 2))
            #expect(window.controller.documentWindow.firstResponder ===
                window.view)
        }
        let controls = window.controller.formatting
        #expect(controls.block.accessibilityLabel() == "Block style")
        #expect(controls.list.accessibilityLabel() == "List")
        #expect(controls.list.selectedItem?.title == "No List")
        #expect(controls.list.accessibilityHelp() ==
            "Current list style: No List")
        let items = try #require(window.controller.documentWindow.toolbar)
            .items
        #expect(items.count == 2)
        #expect(items.map(\.itemIdentifier.rawValue) == [
            "FundamentalBlockStyle", "FundamentalListStyle"
        ])
    }

    @Test("mixed selections expose mixed controls and format in one undo step")
    func mixedSemanticControls() throws
    {
        let window = try WritingTestWindow(
            styles: [.title, .body, .numbered], texts: ["Title", "Body", "Item"]
        )
        defer
        {
            window.close()
        }
        window.select(0, window.view.string.utf16.count)
        let block = window.controller.formatting.block
        #expect(block.selectedItem?.title == "Mixed")
        let list = window.controller.formatting.list
        #expect(list.selectedItem?.title == "Mixed")
        #expect(list.selectedItem?.state == .on)
        #expect(list.item(withTitle: "Mixed")?.isHidden == false)
        try window.choose(.bulleted)
        #expect(window.styles == [.bulleted, .bulleted, .bulleted])
        #expect(window.session.history.undo.count == 1)
        #expect(list.selectedItem?.title == "Bulleted")
        #expect(list.item(withTitle: "Bulleted")?.state == .on)
        #expect(list.item(withTitle: "Numbered")?.state == .off)
        #expect(list.item(withTitle: "Mixed")?.isHidden == true)
        window.view.undoCanonicalEdit(nil)
        #expect(window.styles == [.title, .body, .numbered])
        #expect(block.selectedItem?.title == "Mixed")
        window.view.redoCanonicalEdit(nil)
        #expect(window.styles == [.bulleted, .bulleted, .bulleted])
        try window.chooseNoList()
        #expect(window.styles == [.body, .body, .body])
        #expect(list.selectedItem?.title == "No List")
    }
}
