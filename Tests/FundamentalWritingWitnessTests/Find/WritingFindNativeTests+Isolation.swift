import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingFindNativeTests
{
    @Test("each document retains its own query and case option")
    func isolation() throws
    {
        let first = try WritingTestWindow("One one")
        defer { first.close() }
        first.controller.findText(nil)
        let a = try #require(first.controller.finder)
        a.bar.query.stringValue = "One"
        a.toggleCase(nil)
        let second = try WritingTestWindow("Two two")
        defer { second.close() }
        second.controller.findText(nil)
        let b = try #require(second.controller.finder)
        b.bar.query.stringValue = "two"
        b.refresh()
        #expect(a.caseSensitive)
        #expect(!b.caseSensitive)
        #expect(a.results?.ranges.count == 1)
        #expect(b.results?.ranges.count == 2)
        a.close(nil)
        #expect(!b.bar.isHidden)
        a.show(replacing: false)
        #expect(a.bar.query.stringValue == "One")
        #expect(a.caseSensitive)
        let menu = try #require(a.bar.query.searchMenuTemplate)
        a.menuNeedsUpdate(menu)
        #expect(menu.items.first?.state == .on)
    }

    @Test("opening Find commits marked text once before matching it")
    func composition() throws
    {
        let window = try WritingTestWindow("caf")
        defer { window.close() }
        window.select(3)
        window.view.setMarkedText("e\u{301}",
            selectedRange: NSRange(location: 2, length: 0),
            replacementRange: NSRange(location: NSNotFound, length: 0))
        #expect(window.controller.bridge.composition != nil)
        #expect(window.controller.bridge.projection.text == "caf")
        window.controller.findText(nil)
        #expect(window.controller.bridge.composition == nil)
        let finder = try #require(window.controller.finder)
        finder.bar.query.stringValue = "é"
        finder.nextMatch(nil)
        try window.expect("cafe\u{301}",
                          selection: NSRange(location: 3, length: 2))
        finder.close(nil)
        window.controller.bridge.move(.undo, in: window.view)
        #expect(window.view.string == "caf")
    }
}
