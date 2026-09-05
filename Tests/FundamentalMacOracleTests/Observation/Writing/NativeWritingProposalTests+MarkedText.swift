import AppKit
import Testing

extension NativeWritingProposalTests
{
    @Test("direct marked text has a lifecycle beyond committed input")
    func markedText()
    {
        let fixture = NativeWritingWindow("a")
        defer { fixture.window.close() }
        fixture.view.setMarkedText(
            "e",
            selectedRange: NSRange(location: 1, length: 0),
            replacementRange: NSRange(location: NSNotFound, length: 0)
        )
        fixture.expectSpelling("ae")
        #expect(fixture.view.hasMarkedText())
        #expect(fixture.view.markedRange() == NSRange(
            location: 1,
            length: 1
        ))
        fixture.view.insertText(
            "e\u{0301}",
            replacementRange: NSRange(location: NSNotFound, length: 0)
        )
        fixture.expectSpelling("ae\u{0301}")
        #expect(!fixture.view.hasMarkedText())
        #expect(fixture.view.markedRange().length == 0)
        print("WRITING committed markedRange=\(fixture.view.markedRange())")
        #expect(fixture.view.selectedRange() == NSRange(
            location: 3,
            length: 0
        ))
        #expect(fixture.observer.observations.contains(.changed(
            Array("ae\u{0301}".utf16)
        )))
        let refused = NativeWritingWindow("a")
        defer { refused.window.close() }
        refused.observer.admission = .refuse
        refused.view.setMarkedText(
            "e",
            selectedRange: NSRange(location: 1, length: 0),
            replacementRange: NSRange(location: NSNotFound, length: 0)
        )
        print("WRITING veto marked=\(refused.view.hasMarkedText())")
        print("WRITING veto range=\(refused.view.markedRange())")
        print("WRITING veto units=\(Array(refused.view.string.utf16))")
        refused.expectSpelling("a")
        #expect(!refused.view.hasMarkedText())
        #expect(refused.view.markedRange().length == 0)
        refused.expectProposal(
            NSRange(location: 1, length: 0),
            replacement: "e",
            before: "a"
        )
    }
}
