import Foundation
import Testing

@testable import FundamentalDocument

struct CodeConversionTestValue
{
    static func code(
        _ runs: [SemanticRun], language: String? = nil
    ) throws -> SemanticBlock
    {
        guard let language
        else
        {
            return .code(.plain(PlainSemanticCodeBlock(runs: runs)))
        }
        return .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
            runs: runs,
            language: try #require(SemanticCodeLanguageIdentifier(language))
        )))
    }

    static func identities(_ count: Int) -> [FundamentalBlockID]
    {
        (0 ..< count).map { _ in FundamentalBlockID(UUID()) }
    }

    static func applying(
        _ conversion: SemanticCodeConversion,
        to source: CanonicalDocument
    ) throws -> CanonicalDocument
    {
        let applied = try #require(AppliedSemanticCodeConversion(
            conversion, in: source
        ))
        return CanonicalDocument(
            documentID: source.documentID,
            revision: try #require(DocumentRevision(after: source.revision)),
            content: applied.content
        )
    }

    static func runs(_ block: IdentifiedSemanticBlock) throws -> [SemanticRun]
    {
        try #require(EditableSemanticBlock(block.block)).runs
    }

    static func expectText(
        _ document: CanonicalDocument, _ expected: [String]
    )
    {
        #expect(SemanticWritingTestDocument.texts(document).map
            { Array($0.utf16) } == expected.map { Array($0.utf16) })
    }

    static func language(_ document: CanonicalDocument) -> String?
    {
        guard case let .code(.languageTagged(code)) =
            document.content.blocks[0].block
        else
        {
            return nil
        }
        return code.language.value
    }
}
