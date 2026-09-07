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
        #expect(controls.bulleted.accessibilityLabel() == "Bulleted list")
        #expect(controls.numbered.accessibilityLabel() == "Numbered list")
        #expect(controls.bulleted.image != nil)
        #expect(controls.numbered.image != nil)
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
        #expect(window.controller.formatting.numbered.state == .mixed)
        let bulleted = window.controller.formatting.bulleted
        #expect(bulleted.sendAction(bulleted.action, to: bulleted.target))
        #expect(window.styles == [.bulleted, .bulleted, .bulleted])
        #expect(window.session.history.undo.count == 1)
        #expect(window.controller.formatting.bulleted.state == .on)
        window.view.undoCanonicalEdit(nil)
        #expect(window.styles == [.title, .body, .numbered])
        #expect(block.selectedItem?.title == "Mixed")
        window.view.redoCanonicalEdit(nil)
        #expect(window.styles == [.bulleted, .bulleted, .bulleted])
        #expect(bulleted.sendAction(bulleted.action, to: bulleted.target))
        #expect(window.styles == [.body, .body, .body])
        #expect(window.controller.formatting.bulleted.state == .off)
    }
}
