import AppKit
import Testing

extension NativeWritingProposalTests
{
    @Test("native private pasteboard reading submits exact plain text")
    func privatePasteboard()
    {
        let fixture = NativeWritingWindow("ab")
        defer { fixture.window.close() }
        let pasteboard = NSPasteboard.withUniqueName()
        defer { pasteboard.releaseGlobally() }
        #expect(pasteboard.setString("e\u{0301}", forType: .string))
        #expect(fixture.view.readSelection(from: pasteboard, type: .string))
        fixture.expectSpelling("abe\u{0301}")
        fixture.expectProposal(
            NSRange(location: 2, length: 0),
            replacement: "e\u{0301}",
            before: "ab"
        )
    }

    @Test("selection changes are distinct from proposed text edits")
    func selection()
    {
        let fixture = NativeWritingWindow("abcd")
        defer { fixture.window.close() }
        let range = NSRange(location: 1, length: 2)
        fixture.view.setSelectedRange(range)
        fixture.expectSpelling("abcd")
        #expect(fixture.observer.observations == [.selected(range)])
    }
}
