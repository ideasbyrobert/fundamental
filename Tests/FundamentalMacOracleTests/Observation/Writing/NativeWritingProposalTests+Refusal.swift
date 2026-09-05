import AppKit
import Testing

extension NativeWritingProposalTests
{
    @Test(
        "veto leaves insertion and replacement unchanged before retry",
        arguments: [NSRange(location: 1, length: 0),
                    NSRange(location: 1, length: 2)]
    )
    func veto(_ range: NSRange)
    {
        let fixture = NativeWritingWindow("abcd")
        defer { fixture.window.close() }
        fixture.view.setSelectedRange(range)
        fixture.observer.observations = []
        fixture.observer.admission = .refuse
        fixture.view.insertText("X", replacementRange: range)
        fixture.expectSpelling("abcd")
        fixture.expectProposal(range, replacement: "X", before: "abcd")
        #expect(fixture.view.selectedRange() == range)
        #expect(!fixture.view.hasMarkedText())
        let changed = fixture.observer.observations.contains(
            where: \.isTextChange
        )
        #expect(!changed)
        fixture.observer.admission = .permit
        fixture.observer.observations = []
        fixture.view.insertText("X", replacementRange: range)
        fixture.expectSpelling(range.length == 0 ? "aXbcd" : "aXd")
        fixture.expectProposal(range, replacement: "X", before: "abcd")
    }

    @Test("vetoed native input can finish with a reconstructed projection")
    func reconstruction()
    {
        let fixture = NativeWritingWindow("ab")
        defer { fixture.window.close() }
        let caret = NSRange(location: 3, length: 0)
        fixture.observer.admission = .reconstruct("abc", caret)
        fixture.view.insertText(
            "c",
            replacementRange: NSRange(location: 2, length: 0)
        )
        fixture.expectSpelling("abc")
        fixture.expectProposal(
            NSRange(location: 2, length: 0),
            replacement: "c",
            before: "ab"
        )
        #expect(fixture.view.selectedRange() == caret)
        #expect(!fixture.view.hasMarkedText())
    }
}
