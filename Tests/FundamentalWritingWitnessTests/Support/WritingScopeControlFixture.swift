import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

enum WritingScopeControlFixture
{
    static func attributes(_ value: String, kind: WritingScopeKind) throws
        -> SemanticRunAttributes
    {
        let scopes: SemanticRunScopes
        switch kind
        {
        case .link:
            scopes = .link(try #require(SemanticLinkDestination(value)))
        case .language:
            scopes = .language(try #require(SemanticLanguageIdentifier(value)))
        }
        return .scoped(traits: [.strong], scopes: scopes)
    }

    static func document(kind: WritingScopeKind) throws -> WritingTestDocument
    {
        let runs = try zip(["A", "B"], ["é", "e\u{301}"]).map
        {
            SemanticRun(text: $0.0,
                        attributes: try attributes($0.1, kind: kind))
        }
        return try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: runs))
        ], start: 0, end: 2)
    }
}
