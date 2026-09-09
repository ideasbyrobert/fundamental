import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: [false, true])
    func codeBoundaryReplacementUsesOneCanonicalTransaction(tagged: Bool)
        throws
    {
        let fixture = try WritingCodeFixture.document("A\nB", tagged: tagged)
        let window = try WritingTestWindow(session: DocumentSession(
            state: fixture.state
        ))
        defer
        {
            window.close()
        }
        for range in [NSRange(location: 6, length: 1),
                      NSRange(location: 10, length: 1)]
        {
            window.select(range.location, range.length)
            window.commit("X\nY")
            let after = window.session.document.content
            let expected = ("Before\nA\nB\nAfter" as NSString)
                .replacingCharacters(in: range, with: "X\nY")
            try window.expect(expected, selection: NSRange(
                location: range.location + 3, length: 0
            ))
            #expect(window.session.history.undo.count == 1)
            window.view.undoCanonicalEdit(nil)
            #expect(window.session.document.content ==
                fixture.state.snapshot.document.content)
            try window.expect("Before\nA\nB\nAfter", selection: range)
            window.view.redoCanonicalEdit(nil)
            #expect(window.session.document.content == after)
            window.view.undoCanonicalEdit(nil)
        }
    }
}
