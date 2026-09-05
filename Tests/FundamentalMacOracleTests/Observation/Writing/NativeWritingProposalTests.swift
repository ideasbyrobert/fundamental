import AppKit
import Testing

@Suite("Native writing proposals", .serialized)
@MainActor
struct NativeWritingProposalTests
{
    @Test("the real window keeps an explicit textkit two first responder")
    func nativeWindow()
    {
        let fixture = NativeWritingWindow()
        defer { fixture.window.close() }
        #expect(fixture.window.isVisible)
        #expect(fixture.window.firstResponder === fixture.view)
        #expect(fixture.view.textLayoutManager != nil)
        #expect(!fixture.view.allowsUndo)
        #expect(!fixture.view.hasMarkedText())
    }

    @Test("synthetic key insertion proposes old spelling before change")
    func keyInsertion() throws
    {
        let fixture = NativeWritingWindow("ab")
        defer { fixture.window.close() }
        try fixture.key("c", code: 8)
        fixture.expectSpelling("abc")
        fixture.expectProposal(
            NSRange(location: 2, length: 0),
            replacement: "c",
            before: "ab"
        )
        let observations = fixture.observer.observations
        #expect(observations.contains(.changed(Array("abc".utf16))))
        let proposalIndex = observations.firstIndex(where: \.isProposal)
        let changeIndex = observations.firstIndex(where: \.isTextChange)
        let proposal = try #require(proposalIndex)
        let change = try #require(changeIndex)
        #expect(proposal < change)
        #expect(fixture.view.selectedRange() == NSRange(
            location: 3,
            length: 0
        ))
    }

    @Test("committed replacement preserves decomposed spelling")
    func selectedReplacement()
    {
        let fixture = NativeWritingWindow("abcd")
        defer { fixture.window.close() }
        let range = NSRange(location: 1, length: 2)
        fixture.view.setSelectedRange(range)
        fixture.observer.observations = []
        fixture.view.insertText("e\u{0301}", replacementRange: range)
        fixture.expectSpelling("ae\u{0301}d")
        fixture.expectProposal(
            range,
            replacement: "e\u{0301}",
            before: "abcd"
        )
    }
}
