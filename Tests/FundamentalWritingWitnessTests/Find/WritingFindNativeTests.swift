import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

@MainActor
@Suite("Native Find and Replace", .serialized)
struct WritingFindNativeTests
{
    @Test("Find selects source and Replace All has one canonical undo")
    func replacement() throws
    {
        let state = try WritingTestDocument("Мир мир e\u{301} é").state
        let window = try WritingTestWindow(session: DocumentSession(
            state: state, initiallySaved: true
        ))
        defer { window.close() }
        let controller = window.controller
        controller.findAndReplace(nil)
        let finder = try #require(controller.finder)
        finder.bar.query.stringValue = "мир"
        finder.refresh()
        #expect(finder.results?.ranges.count == 2)
        finder.nextMatch(nil)
        try window.expect("Мир мир e\u{301} é",
                          selection: NSRange(location: 0, length: 3))
        finder.previousMatch(nil)
        #expect(window.view.selectedRange() == NSRange(location: 4, length: 3))
        let before = window.storage
        finder.bar.replacement.stringValue = "Свет"
        finder.replaceAll(nil)
        try window.expect("Свет Свет e\u{301} é",
                          selection: NSRange(location: 4, length: 0))
        #expect(controller.documentWindow.firstResponder === window.view)
        #expect(window.session.isDirty)
        controller.bridge.move(.undo, in: window.view)
        let restored = try #require(WritingProjection(window.session.state))
        let previous = try #require(WritingProjection(before.state))
        #expect(restored.snapshot.snapshot.document.content ==
            previous.snapshot.snapshot.document.content)
        #expect(restored.selection == previous.selection)
        #expect(!window.session.isDirty)
        controller.bridge.move(.redo, in: window.view)
        try window.expect("Свет Свет e\u{301} é",
                          selection: NSRange(location: 4, length: 0))
    }

    @Test("invalid replacement leaves content and history intact with feedback")
    func refusal() throws
    {
        let window = try WritingTestWindow("cat cat")
        defer { window.close() }
        window.controller.findAndReplace(nil)
        let finder = try #require(window.controller.finder)
        finder.bar.query.stringValue = "cat"
        finder.bar.replacement.stringValue = "two\nlines"
        let before = window.storage
        finder.replaceAll(nil)
        #expect(window.storage == before)
        #expect(!finder.bar.message.isHidden)
        #expect(finder.bar.message.stringValue.contains("one line"))
        finder.bar.replacement.stringValue = ""
        finder.replaceAll(nil)
        #expect(window.view.string == " ")
        #expect(finder.bar.message.isHidden)
        window.controller.bridge.move(.undo, in: window.view)
        #expect(window.view.string == "cat cat")
    }
}
