import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("Format refuses inactive documents and file-panel context")
    func formatRefusesNonEditingTargets() throws
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
        let item = try first.formatChoice("Heading", group: "Paragraph Style")
        let firstState = first.storage
        #expect(!first.controller.validateUserInterfaceItem(item))
        first.controller.chooseParagraphStyle(item)
        #expect(first.storage == firstState)
        #expect(second.controller.validateUserInterfaceItem(item))
        second.controller.documentWindow.beginSheet(sheet)
        #expect(second.controller.documentWindow.attachedSheet === sheet)
        let secondState = second.storage
        #expect(!second.controller.validateUserInterfaceItem(item))
        #expect(item.state == .off)
        second.controller.chooseParagraphStyle(item)
        #expect(second.storage == secondState)
    }

    @Test("Format rejects unknown or mismatched choices atomically")
    func formatRefusesInvalidChoice() throws
    {
        let window = try WritingTestWindow("Exact e\u{301}😀")
        defer
        {
            window.close()
        }
        let before = window.storage
        let item = try window.formatChoice("Heading", group: "Paragraph Style")
        for value in ["unknown", "monostyled", "numbered"]
        {
            item.representedObject = value
            #expect(!window.controller.validateUserInterfaceItem(item))
            window.controller.chooseParagraphStyle(item)
        }
        window.controller.chooseParagraphStyle(nil)
        window.controller.choosingLocation = true
        let list = try window.formatChoice("Numbered", group: "List")
        #expect(!window.controller.validateUserInterfaceItem(list))
        window.controller.chooseListStyle(list)
        window.controller.choosingLocation = false
        #expect(window.storage == before)
    }
}
