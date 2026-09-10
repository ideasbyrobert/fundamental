import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("Text commands stay with the active editor and refuse panel context")
    func inlineControlsRouting() throws
    {
        let first = try WritingTestWindow("First")
        let second = try WritingTestWindow("Second")
        let sheet = NSPanel(contentRect: NSRect(x: 0, y: 0,
                                                width: 200, height: 100),
                            styleMask: [.titled], backing: .buffered,
                            defer: false)
        sheet.isReleasedWhenClosed = false
        defer
        {
            second.controller.documentWindow.endSheet(sheet)
            sheet.close()
            second.close()
            first.close()
        }
        let item = try first.formatChoice("Bold", group: "Text Style")
        let original = first.storage
        #expect(!first.controller.validateUserInterfaceItem(item))
        first.controller.chooseTextStyle(item)
        #expect(first.storage == original)
        try second.performFormat(item)
        try second.expectInline(.strong, .on)
        #expect(first.storage == original)
        let retained = second.storage
        second.controller.documentWindow.beginSheet(sheet)
        #expect(!second.controller.validateUserInterfaceItem(item))
        #expect(item.state == .off)
        second.controller.chooseTextStyle(item)
        #expect(second.storage == retained)
    }

    @Test("unknown and unavailable Text choices cannot change the document")
    func inlineControlsRefusal() throws
    {
        let window = try WritingTestWindow("Exact e\u{301}😀")
        defer
        {
            window.close()
        }
        let before = window.storage
        let item = try window.formatChoice("Bold", group: "Text Style")
        item.representedObject = "body"
        #expect(!window.controller.validateUserInterfaceItem(item))
        window.controller.chooseTextStyle(item)
        window.controller.chooseTextStyle(nil)
        item.representedObject = "strong"
        window.controller.choosingLocation = true
        #expect(!window.controller.validateUserInterfaceItem(item))
        window.controller.chooseTextStyle(item)
        window.controller.choosingLocation = false
        window.view.isEditable = false
        #expect(!window.controller.validateUserInterfaceItem(item))
        window.controller.chooseTextStyle(item)
        #expect(window.storage == before)
    }
}
