import Testing

@testable import FundamentalDocument
@testable import FundamentalProjection

extension ProjectionListTests
{
    @Test("list context preserves traits scopes and exact Unicode sources",
          arguments: SemanticListKind.allCases)
    func sourceMeaning(_ kind: SemanticListKind) throws
    {
        let traits: Set<SemanticInlineTrait> = [
            .strong, .emphasis, .underline, .strikethrough, .inlineCode,
            .superscript, .subscriptText
        ]
        let text = "1. e\u{301}😀 Раздел"
        let link = try #require(SemanticLinkDestination(
            " https://example.invalid/e\u{301} "
        ))
        let language = try #require(SemanticLanguageIdentifier(" ru-RU "))
        let runs: [SemanticRun] = [
            .direct(SemanticDirectRun(text: "", traits: [])),
            .scoped(SemanticScopedRun(text: text, traits: traits,
                scopes: .linkAndLanguage(link: link, language: language)))
        ]
        let projection = try ProjectionFixture.projection([
            ProjectionListFixture.body(),
            .listItem(SemanticListItem(kind: kind, runs: runs)),
            ProjectionListFixture.item(kind, "")
        ])
        let block = projection.blocks[1]
        let prose = try ProjectionListFixture.prose(block)
        #expect(projection.lineage.documentID == ProjectionFixture.documentID)
        #expect(projection.lineage.revision == 7)
        #expect(projection.lineage.generation == 9)
        #expect(prose.runs[0] == .direct(source: .block(
            blockID: block.source.blockID, run: 0,
            range: ProjectedUTF16Range(0 ..< 0)
        ), text: "", traits: []))
        #expect(prose.runs[1] == .scoped(source: .block(
            blockID: block.source.blockID, run: 1,
            range: ProjectedUTF16Range(0 ..< text.utf16.count)
        ), text: text, traits: [
            .strong, .emphasis, .underline, .strikethrough, .inlineCode,
            .superscript, .subscriptText
        ], scope: .linkAndLanguage(
            link: " https://example.invalid/e\u{301} ", language: " ru-RU "
        )))
        #expect(prose.runs.flatMap { Array($0.text.utf16) } ==
            Array(text.utf16))
        #expect(ProjectionListFixture.position(block)?.index == 0)
        #expect(ProjectionListFixture.position(block)?.count == 2)
    }
}
