import Testing

@testable import FundamentalDocument

extension InheritedTypingAttributesTests
{
    @Test("block seams inherit selected source without crossing an empty caret")
    func blocks() throws
    {
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "A", traits: [.strong])
            ])),
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "", traits: [.underline])
            ])),
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "B", traits: [.emphasis])
            ]))
        ])
        let cases: [(DocumentRange, SemanticRunAttributes)] = [
            (try source.range((1, 0), (1, 0)), .direct(traits: [])),
            (try source.range((2, 0), (2, 0)), .direct(traits: [.emphasis])),
            (try source.range((0, 1), (2, 0)), .direct(traits: [.strong])),
            (try source.range((2, 1), (0, 1)), .direct(traits: [.emphasis]))
        ]
        for (range, expected) in cases
        {
            #expect(InheritedTypingAttributes(range, in: source.document)?
                .attributes == expected)
        }
    }

    @Test("CRLF and table boundaries remain unavailable to inheritance")
    func invalidBoundaries() throws
    {
        let source = try SemanticWritingTestDocument(
            [.monostyled], texts: ["A\r\nB"]
        )
        #expect(try InheritedTypingAttributes(
            source.range((0, 2), (0, 2)), in: source.document
        ) == nil)
        for table in try BlockRecordTestValue.tables()
        {
            let source = try SemanticWritingTestDocument(blocks: [
                .paragraph(SemanticParagraph(runs: [])), .table(table),
                .paragraph(SemanticParagraph(runs: []))
            ])
            #expect(try InheritedTypingAttributes(
                source.range((0, 0), (2, 0)), in: source.document
            ) == nil)
        }
    }
}
