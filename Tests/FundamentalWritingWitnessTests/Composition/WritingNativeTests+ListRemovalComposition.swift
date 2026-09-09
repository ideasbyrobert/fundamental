import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("list removal commits preedit before removing its role")
    func noListCommitsComposition() throws
    {
        let window = try WritingTestWindow(styles: [.numbered], texts: [""])
        defer
        {
            window.close()
        }
        let before = window.session.document.content
        window.mark("題名")
        #expect(window.session.document.content == before)
        try window.chooseNoList()
        #expect(!window.view.hasMarkedText())
        #expect(window.view.string == "題名")
        #expect(window.styles == [.body])
        #expect(window.session.history.undo.count == 2)
        window.view.undoCanonicalEdit(nil)
        #expect(window.styles == [.numbered])
        #expect(window.view.string == "題名")
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == before)
        #expect(!window.session.isDirty)
    }
}
