import Testing

@testable import FundamentalDocument
@testable import FundamentalProjection

extension ProjectionProseTests
{
    @Test("run scopes traits and UTF-16 ranges remain exact")
    func runFactsAndRangesRemainExact() throws
    {
        let allTraits: Set<SemanticInlineTrait> = [
            .strong,
            .emphasis,
            .underline,
            .strikethrough,
            .inlineCode,
            .superscript,
            .subscriptText
        ]
        let runs = [
            ProjectionFixture.direct("A", traits: allTraits),
            ProjectionFixture.direct(""),
            try ProjectionFixture.scoped("😀")
        ]
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: runs))
        let projection = try ProjectionFixture.projection([block])
        guard case let .prose(_, prose) = projection.firstBlock
        else
        {
            Issue.record("Expected prose")
            return
        }

        #expect(prose.runs.map(\.text) == ["A", "", "😀"])
        #expect(prose.runs[0].traits == [
            .strong,
            .emphasis,
            .underline,
            .strikethrough,
            .inlineCode,
            .superscript,
            .subscriptText
        ])
        let emptyRange = ProjectedUTF16Range(1..<1)
        #expect(prose.runs[1].source == .block(
            blockID: projection.firstBlock.source.blockID,
            run: 1,
            range: emptyRange
        ))
        let emojiRange = ProjectedUTF16Range(1..<3)
        #expect(prose.runs[2].source == .block(
            blockID: projection.firstBlock.source.blockID,
            run: 2,
            range: emojiRange
        ))
        guard case let .scoped(_, _, _, scope) = prose.runs[2]
        else
        {
            Issue.record("Expected scoped run")
            return
        }
        #expect(scope == .linkAndLanguage(
            link: "https://a.test",
            language: "hy"
        ))
    }

    @Test("plain and language-tagged code remain distinct")
    func codeFormsRemainDistinct() throws
    {
        let language = try #require(SemanticCodeLanguageIdentifier("swift"))
        let blocks = [
            SemanticBlock.code(.plain(PlainSemanticCodeBlock(runs: []))),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: [ProjectionFixture.direct("let")],
                language: language
            )))
        ]
        let projection = try ProjectionFixture.projection(blocks)

        guard case .code(_, .plain([])) = projection.blocks[0],
              case let .code(_, .languageTagged(tag, runs))
                = projection.blocks[1]
        else
        {
            Issue.record("Expected both code forms")
            return
        }
        #expect(tag == "swift")
        #expect(runs.map(\.text) == ["let"])
    }
}
