import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

enum LayoutFixture
{
    static let documentID = UUID(uuid: (
        0x10, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1
    ))

    static func blockID(_ ordinal: Int) -> UUID
    {
        UUID(uuid: (
            0x20, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, UInt8(ordinal + 1)
        ))
    }

    static func projection(
        _ blocks: [SemanticBlock]
    ) throws -> ProjectionSnapshot
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
        let snapshot = DocumentSnapshot(
            generation: SnapshotGeneration(9),
            document: CanonicalDocument(
                documentID: FundamentalDocumentID(documentID),
                revision: DocumentRevision(7),
                content: content
            )
        )
        return ProjectionSnapshot(snapshot)
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
        let destination = try #require(
            SemanticLinkDestination("https://a.test")
        )
        return .scoped(SemanticScopedRun(
            text: text,
            traits: [.emphasis],
            scopes: .link(destination)
        ))
    }

    static func request(
        width: Double,
        generation: UInt64 = 11
    ) throws -> LayoutRequest
    {
        try #require(LayoutRequest(
            generation: generation,
            width: width,
            blockSpacing: 12,
            rowSpacing: 4,
            columnSpacing: 6,
            cellPadding: 5
        ))
    }
}
