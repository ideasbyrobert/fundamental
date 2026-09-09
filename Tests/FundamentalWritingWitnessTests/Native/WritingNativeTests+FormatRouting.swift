import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("Format routes to the active document and retains its selection")
    func formatRoutesToActiveDocument() throws
    {
        let first = try WritingTestWindow("A😀B")
        let second = try WritingTestWindow("Other")
        defer
        {
            second.close()
            first.close()
        }
        first.controller.showWindow(nil)
        first.select(1, 2)
        let other = second.storage
        let heading = try first.formatChoice("Heading",
                                             group: "Paragraph Style")
        #expect(first.controller.validateUserInterfaceItem(heading))
        try first.performFormat(heading)
        #expect(first.styles == [.heading])
        #expect(second.storage == other)
        try first.expect("A😀B", selection: NSRange(location: 1, length: 2))
        #expect(first.controller.documentWindow.firstResponder === first.view)
        second.controller.showWindow(nil)
        second.select(0, 5)
        let firstState = first.storage
        let numbered = try second.formatChoice("Numbered", group: "List")
        try second.performFormat(numbered)
        #expect(second.styles == [.numbered])
        #expect(first.storage == firstState)
        try second.key("X", code: 7)
        try second.expect("X", selection: NSRange(location: 1, length: 0))
        second.view.undoCanonicalEdit(nil)
        second.view.undoCanonicalEdit(nil)
        #expect(second.styles == [.body])
        try second.expect("Other", selection: NSRange(location: 0, length: 5))
    }

    @Test("Format validation reports partial choices without editing history")
    func formatStateIsObservational() throws
    {
        let window = try WritingTestWindow(
            styles: [.heading, .numbered], texts: ["Heading", "Item"]
        )
        defer
        {
            window.close()
        }
        window.select(0, window.view.string.utf16.count)
        let before = window.storage
        for (title, expected) in [("No List", NSControl.StateValue.mixed),
                                  ("Numbered", .mixed), ("Bulleted", .off)]
        {
            let item = try window.formatChoice(title, group: "List")
            #expect(window.controller.validateUserInterfaceItem(item))
            #expect(item.state == expected)
        }
        #expect(window.storage == before)
        let remove = try window.formatChoice("No List", group: "List")
        try window.performFormat(remove)
        #expect(window.styles == [.heading, .body])
        #expect(window.session.history.undo.count == 1)
        #expect(window.controller.validateUserInterfaceItem(remove))
        #expect(remove.state == .on)
        let removed = window.storage
        try window.performFormat(remove)
        #expect(window.storage == removed)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == before.state.snapshot
            .document.content)
    }
}
