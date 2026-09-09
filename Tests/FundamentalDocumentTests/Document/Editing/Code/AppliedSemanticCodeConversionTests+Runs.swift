import Testing

@testable import FundamentalDocument

extension AppliedSemanticCodeConversionTests
{
    @Test("CRLF across runs preserves attributes and every empty run")
    func splitAttributedRuns() throws
    {
        let link = try #require(SemanticLinkDestination("https://example.test"))
        let empty = SemanticRun.scoped(SemanticScopedRun(
            text: "", traits: [.underline], scopes: .link(link)
        ))
        let first = SemanticRun(text: "e\u{301}\r", traits: [.strong])
        let last = SemanticRun.scoped(SemanticScopedRun(
            text: "\n\t😀\r\n", traits: [.emphasis], scopes: .link(link)
        ))
        let runs = [SemanticRun(text: ""), first, empty, last, empty]
        let source = try SemanticWritingTestDocument(blocks: [
            CodeConversionTestValue.code(runs, language: " Swift ")
        ])
        let result = try CodeConversionTestValue.applying(
            #require(SemanticCodeConversion(
                range: source.range((0, 0), (0, 0)), proseStyle: .body,
                continuationBlockIDs: CodeConversionTestValue.identities(2)
            )),
            to: source.document
        )
        CodeConversionTestValue.expectText(result, ["e\u{301}", "\t😀", ""])
        let expected: [[SemanticRun]] = [
            [SemanticRun(text: ""), SemanticRun(
                text: "e\u{301}", traits: [.strong]
            )],
            [empty, .scoped(SemanticScopedRun(
                text: "\t😀", traits: [.emphasis], scopes: .link(link)
            ))],
            [empty]
        ]
        for (block, runs) in zip(result.content.blocks, expected)
        {
            #expect(try CodeConversionTestValue.runs(block) == runs)
        }
    }

    @Test("empty runs at a consumed terminator attach to its following line")
    func emptyRunAtTerminator() throws
    {
        let empty = SemanticRun(text: "", traits: [.inlineCode])
        let runs = [SemanticRun(text: "A"), empty,
                    SemanticRun(text: "\r"), empty,
                    SemanticRun(text: "\n"), empty,
                    SemanticRun(text: "B"), empty]
        let source = try SemanticWritingTestDocument(blocks: [
            CodeConversionTestValue.code(runs)
        ])
        let result = try CodeConversionTestValue.applying(
            #require(SemanticCodeConversion(
                range: source.range((0, 0), (0, 0)), proseStyle: .body,
                continuationBlockIDs: CodeConversionTestValue.identities(1)
            )),
            to: source.document
        )
        #expect(try CodeConversionTestValue.runs(result.content.blocks[0]) ==
            [SemanticRun(text: "A")])
        #expect(try CodeConversionTestValue.runs(result.content.blocks[1]) ==
            [empty, empty, empty, SemanticRun(text: "B"), empty])
    }
}
