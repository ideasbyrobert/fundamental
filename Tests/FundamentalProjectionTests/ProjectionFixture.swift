import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalProjection

enum ProjectionFixture
{
    static let documentID = UUID(
        uuidString: "10000000-0000-0000-0000-000000000001"
    )!

    static func blockID(_ ordinal: Int) -> UUID
    {
        UUID(uuid: (
            0x20, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, UInt8(ordinal + 1)
        ))
    }

    static func snapshot(
        _ blocks: [SemanticBlock]
    ) throws -> DocumentSnapshot
    {
        let identified = blocks.enumerated().map
        {
            IdentifiedSemanticBlock(
                blockID: FundamentalBlockID(blockID($0.offset)),
                block: $0.element
            )
        }
        let first = try #require(identified.first)
        let content = try #require(CanonicalDocumentContent(
            firstBlock: first,
            remainingBlocks: Array(identified.dropFirst())
        ))
        return DocumentSnapshot(
            generation: SnapshotGeneration(9),
            document: CanonicalDocument(
                documentID: FundamentalDocumentID(documentID),
                revision: DocumentRevision(7),
                content: content
            )
        )
    }

    static func direct(
        _ text: String,
        traits: Set<SemanticInlineTrait> = []
    ) -> SemanticRun
    {
        .direct(SemanticDirectRun(
            text: text,
            traits: traits
        ))
    }

    static func scoped(_ text: String) throws -> SemanticRun
    {
        let link = try #require(SemanticLinkDestination("https://a.test"))
        let language = try #require(SemanticLanguageIdentifier("hy"))
        return .scoped(SemanticScopedRun(
            text: text,
            traits: [.emphasis],
            scopes: .linkAndLanguage(
                link: link,
                language: language
            )
        ))
    }

    static func projection(
        _ blocks: [SemanticBlock]
    ) throws -> ProjectionSnapshot
    {
        ProjectionSnapshot(try snapshot(blocks))
    }
}
