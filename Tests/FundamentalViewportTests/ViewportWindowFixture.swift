import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalProjection

enum ViewportWindowFixture
{
    static let documentID = UUID(uuid: (
        0x77, 0x20, 0x26, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1
    ))

    static func blockID(_ ordinal: Int) -> UUID
    {
        let value = UInt64(ordinal + 1)
        return UUID(uuid: (
            0x77, 0x20, 0x26, 0, 0, 0, 0, 0,
            UInt8(truncatingIfNeeded: value >> 56),
            UInt8(truncatingIfNeeded: value >> 48),
            UInt8(truncatingIfNeeded: value >> 40),
            UInt8(truncatingIfNeeded: value >> 32),
            UInt8(truncatingIfNeeded: value >> 24),
            UInt8(truncatingIfNeeded: value >> 16),
            UInt8(truncatingIfNeeded: value >> 8),
            UInt8(truncatingIfNeeded: value)
        ))
    }

    static func run(
        _ text: String,
        traits: Set<SemanticInlineTrait> = []
    ) -> SemanticRun
    {
        .direct(SemanticDirectRun(text: text, traits: traits))
    }

    static func projection(
        _ blocks: [SemanticBlock],
        generation: UInt64 = 9
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
        let document = CanonicalDocument(
            documentID: FundamentalDocumentID(documentID),
            revision: DocumentRevision(7),
            content: content
        )
        return ProjectionSnapshot(DocumentSnapshot(
            generation: SnapshotGeneration(generation),
            document: document
        ))
    }
}
