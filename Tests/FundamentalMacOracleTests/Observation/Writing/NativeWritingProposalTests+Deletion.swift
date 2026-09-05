import AppKit
import Testing

extension NativeWritingProposalTests
{
    @Test(
        "native backward deletion reveals the requested scalar extent",
        arguments: ["e\u{0301}", "\u{0915}\u{093F}", "\u{1F642}"]
    )
    func backwardDeletion(_ spelling: String) throws
    {
        let fixture = NativeWritingWindow(spelling)
        defer { fixture.window.close() }
        try fixture.key("\u{007F}", code: 51)
        let devanagari = spelling.utf16.first == 0x0915
        fixture.expectSpelling(devanagari ? "\u{0915}" : "")
        fixture.expectProposal(
            NSRange(location: devanagari ? 1 : 0,
                    length: devanagari ? 1 : 2),
            replacement: "",
            before: spelling
        )
    }

    @Test("synthetic forward deletion preserves a surrogate pair")
    func forwardDeletion() throws
    {
        let fixture = NativeWritingWindow("\u{1F642}b")
        defer { fixture.window.close() }
        fixture.view.setSelectedRange(NSRange(location: 0, length: 0))
        fixture.observer.observations = []
        try fixture.key("\u{F728}", code: 117)
        fixture.expectSpelling("b")
        fixture.expectProposal(
            NSRange(location: 0, length: 2),
            replacement: "",
            before: "\u{1F642}b"
        )
    }
}
