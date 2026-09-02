import Testing

@testable import FundamentalDocument

extension ResolvedDocumentDeletionRangeTests
{
    @Test("observed scalar deletion exemplars are admitted")
    func observedScalarDeletionExemplarsAreAdmitted() throws
    {
        let examples = [
            ("e\u{301}", 1, 2),
            ("कि", 1, 2),
            ("\u{2708}\u{FE0F}", 1, 2),
            ("👨‍👩‍👧‍👦", 9, 11),
            ("🇦🇲", 2, 4),
            ("👍🏽", 2, 4),
            ("\u{1F1E6}\u{1F1F2}\u{1F1FA}", 2, 4)
        ]

        for example in examples
        {
            let deletion = try Self.deletion(
                texts: [example.0],
                start: example.1,
                end: example.2
            )
            #expect(deletion != nil)
        }
    }

    @Test("a scalar boundary across established runs is admitted")
    func scalarBoundaryAcrossRunsIsAdmitted() throws
    {
        let document = try Self.document(texts: ["e", "\u{301}"])
        let range = try Self.range(start: 1, end: 2)
        let deletion = try #require(ResolvedDocumentDeletionRange(
            range,
            in: document
        ))

        #expect(deletion.lowerUTF16Offset.value == 1)
        #expect(deletion.upperUTF16Offset.value == 2)
        guard case let .paragraph(paragraph) =
            document.content.blocks[0].block
        else
        {
            Issue.record("Expected paragraph")
            return
        }
        #expect(paragraph.runs == [
            SemanticRun(text: "e"),
            SemanticRun(text: "\u{301}")
        ])
    }

    @Test("ordinary point and range resolution remain Character-bound")
    func ordinaryResolutionRemainsCharacterBound() throws
    {
        for text in ["e\u{301}", "कि"]
        {
            let document = try Self.document(texts: [text])
            let interior = try ResolvedDocumentPointTests.point(offset: 1)
            let range = try Self.range(start: 0, end: 1)

            #expect(ResolvedDocumentPoint(interior, in: document) == nil)
            #expect(ResolvedDocumentRange(range, in: document) == nil)
            #expect(ResolvedDocumentDeletionRange(
                try Self.range(start: 1, end: 2),
                in: document
            ) != nil)
        }
    }
}
