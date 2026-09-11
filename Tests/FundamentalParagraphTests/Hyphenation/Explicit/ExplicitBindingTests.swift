@testable import FundamentalParagraph
import Testing

@Suite
struct ExplicitBindingTests
{
    @Test
    func onlyTheSameImmutableParentCanReuseASelection() throws
    {
        let source = try ExplicitFixture.source("a\u{AD}bc")
        let first = ExplicitParagraphHyphens(source)
        let identical = ExplicitParagraphHyphens(source)
        let other = ExplicitParagraphHyphens(
            try ExplicitFixture.source("x\u{AD}yz")
        )
        let selection = try first.select(0)
        for foreign in [identical, other]
        {
            #expect(throws: ExplicitProjectionFailure.foreignSelection)
            {
                try foreign.project(0..<2, end: .opportunity(selection))
            }
        }
        let copy = first
        let original = try first.project(0..<2, end: .opportunity(selection))
        let reused = try copy.project(0..<2, end: .opportunity(selection))
        let local = try other.project(
            0..<2, end: .opportunity(other.select(0))
        )
        #expect(original.text == "a‐")
        #expect(reused.text == original.text)
        #expect(local.text == "x‐")
        #expect(identical.source.paragraph == first.source.paragraph)
        #expect(other.source.source.utf16.count
            == first.source.source.utf16.count)
        for slice in [original, reused, local]
        {
            _ = try ExplicitFixture.reconstructed(slice)
        }
        try PatternEvidence.write(
            "parents", group: "explicit-controls", record: [
                "sameTextParentRejected": true,
                "differentTextSameOffsetRejected": true,
                "copyDisplayUTF16": Array(reused.text.utf16),
                "originalDisplayUTF16": Array(original.text.utf16),
                "otherLocalDisplayUTF16": Array(local.text.utf16)
            ]
        )
    }
}
