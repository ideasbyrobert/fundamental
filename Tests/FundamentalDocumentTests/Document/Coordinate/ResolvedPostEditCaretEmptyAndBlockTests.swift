import Testing

@testable import FundamentalDocument

extension ResolvedPostEditCaretTests
{
    @Test("runless text resolves zero under either affinity")
    func runlessTextResolvesZero() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph([]))
        ])

        for affinity in Self.affinities
        {
            let result = try Self.caretInFirstBlock(
                candidate: 0,
                affinity: affinity,
                in: document
            )
            let caret = try #require(result)
            #expect(caret.resolvedPoint.runPosition == .noRuns)
        }
    }

    @Test("an established empty run resolves zero exactly")
    func establishedEmptyRunResolvesZero() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph([""]))
        ])
        let zero = try #require(DocumentUTF16Offset(0))

        for affinity in Self.affinities
        {
            let result = try Self.caretInFirstBlock(
                candidate: 0,
                affinity: affinity,
                in: document
            )
            let caret = try #require(result)
            #expect(caret.resolvedPoint.runPosition == .run(
                index: 0,
                utf16Offset: zero
            ))
        }
    }

    @Test("every editable block form resolves a valid candidate")
    func everyEditableBlockFormResolves() throws
    {
        let runs = [SemanticRun(text: "e\u{301}")]
        let language = try #require(
            SemanticCodeLanguageIdentifier("swift")
        )
        var blocks: [SemanticBlock] = [
            .paragraph(SemanticParagraph(runs: runs)),
            .heading(.title(TitleSemanticHeading(runs: runs)))
        ]
        blocks += SemanticHeadingLevel.allCases.map
        {
            .heading(.section(SectionSemanticHeading(
                runs: runs,
                level: $0
            )))
        }
        blocks += [
            .code(.plain(PlainSemanticCodeBlock(runs: runs))),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: runs,
                language: language
            )))
        ]

        for block in blocks
        {
            let document = try Self.document(blocks: [(2, block)])
            let offsets = try Self.resolvedOffsets(
                candidate: 1,
                in: document
            )
            #expect(offsets == [0, 2])
        }
    }
}
