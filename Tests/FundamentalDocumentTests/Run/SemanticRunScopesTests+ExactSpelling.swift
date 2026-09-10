import Testing

@testable import FundamentalDocument

extension SemanticRunScopesTests
{
    @Test("scope spelling alone changes canonical content", arguments: 0..<3)
    func exactSpelling(form: Int) throws
    {
        let leftLink = try #require(SemanticLinkDestination("https://a.test/é"))
        let rightLink = try #require(SemanticLinkDestination(
            "https://a.test/e\u{301}"
        ))
        let leftLanguage = try #require(SemanticLanguageIdentifier(" é "))
        let rightLanguage = try #require(SemanticLanguageIdentifier(
            " e\u{301} "
        ))
        let left: [SemanticRunScopes] = [
            .link(leftLink), .language(leftLanguage),
            .linkAndLanguage(link: leftLink, language: leftLanguage)
        ]
        let right: [SemanticRunScopes] = [
            .link(rightLink), .language(rightLanguage),
            .linkAndLanguage(link: rightLink, language: rightLanguage)
        ]
        #expect(left[form] != right[form])
        func block(_ scope: SemanticRunScopes) -> SemanticBlock
        {
            .paragraph(SemanticParagraph(runs: [SemanticRun(
                text: "Exact e\u{301} 😀", attributes: .scoped(
                    traits: [.strong], scopes: scope
                )
            )]))
        }
        let source = try SemanticWritingTestDocument(
            blocks: [block(left[form])]
        )
        let content = try #require(CanonicalDocumentContent(
            firstBlock: IdentifiedSemanticBlock(
                blockID: source.document.content.blocks[0].blockID,
                block: block(right[form])
            ), remainingBlocks: []
        ))
        #expect(content != source.document.content)
        guard case let .editable(state) = try source.state()
        else
        {
            Issue.record("Expected editable source")
            return
        }
        guard case .applied = DocumentSessionTransition.preservingSelection(
            content, in: state
        )
        else
        {
            Issue.record("The exact scope change must not disappear")
            return
        }
    }
}
