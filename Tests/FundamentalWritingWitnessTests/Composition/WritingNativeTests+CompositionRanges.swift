import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("partial marked replacements retain surrounding provisional text")
    func partialReplacement() throws
    {
        let window = try WritingTestWindow("ABCD")
        defer
        {
            window.close()
        }
        window.select(2)
        let before = window.storage
        window.mark("abcd")
        window.mark("漢", replacing: NSRange(location: 3, length: 2))
        #expect(window.storage == before)
        #expect(window.view.string == "ABa漢dCD")
        #expect(window.view.markedRange() == NSRange(location: 3, length: 1))
        window.commit("字")
        try window.expect("ABa字dCD", selection: NSRange(location: 4, length: 0))
        #expect(window.session.history.undo.count == 1)
        window.view.undoCanonicalEdit(nil)
        try window.expect("ABCD", selection: NSRange(location: 2, length: 0))
    }

    @Test("marked replacement can span canonical paragraphs in one edit")
    func paragraphReplacement() throws
    {
        let window = try WritingTestWindow()
        defer
        {
            window.close()
        }
        window.commit("A\nB")
        window.select(0, 3)
        let before = window.storage
        window.mark("か\nな")
        #expect(window.storage == before)
        #expect(window.view.string == "か\nな")
        window.commit("漢\n字")
        try window.expect("漢\n字", selection: NSRange(location: 3, length: 0))
        #expect(window.session.history.undo.count == 2)
        window.view.undoCanonicalEdit(nil)
        try window.expect("A\nB", selection: NSRange(location: 0, length: 3))
    }

    @Test("explicit replacements beyond a mark preserve intervening text",
          arguments: [NSRange(location: 0, length: 1),
                      NSRange(location: 3, length: 3),
                      NSRange(location: 5, length: 2)])
    func expandedReplacement(_ range: NSRange) throws
    {
        let window = try WritingTestWindow("ABCDE")
        defer
        {
            window.close()
        }
        window.select(2)
        window.mark("xy")
        let expected = ("ABxyCDE" as NSString).replacingCharacters(
            in: range, with: "Z"
        )
        window.mark("Z", replacing: range)
        #expect(window.view.string == expected)
        window.view.unmarkText()
        try window.expect(expected, selection: NSRange(
            location: range.location + 1, length: 0
        ))
        #expect(window.session.history.undo.count == 1)
        window.view.undoCanonicalEdit(nil)
        try window.expect("ABCDE", selection: NSRange(location: 2, length: 0))
    }
}
