@testable import FundamentalParagraph
import Testing

@Suite
struct ExplicitHardEndingTests
{
    @Test(arguments: [
        "\n", "\r", "\r\n", "\u{85}", "\u{B}", "\u{C}", "\u{2028}", "\u{2029}"
    ])
    func displaySlicesStayWithinSourceLineContent(_ ending: String) throws
    {
        let text = "a\u{AD}bc" + ending + "next"
        let collection = ExplicitParagraphHyphens(
            try ExplicitFixture.source(text)
        )
        let count = text.utf16.count
        #expect(throws: ExplicitProjectionFailure.hardEnding)
        {
            try collection.project(0..<count)
        }
        #expect(throws: ExplicitProjectionFailure.hardEnding)
        {
            try collection.project(0..<(4 + ending.utf16.count))
        }
        let left = try collection.project(0..<4)
        let right = try collection.project((4 + ending.utf16.count)..<count)
        #expect(left.text == "abc")
        #expect(right.text == "next")
        _ = try ExplicitFixture.reconstructed(left)
        _ = try ExplicitFixture.reconstructed(right)
        try ExplicitEvidence.write(
            "ending-" + OwnedEvidence.spellingName(ending),
            collection: collection, slices: [left, right]
        )
    }
}
