import Foundation
import Testing

@testable import FundamentalDocument

extension MacReaderDocumentFixture
{
    static func source(
        _ blocks: [SemanticBlock], seed: UInt8 = 0x88,
        revision: UInt64 = 7, generation: UInt64 = 9
    ) throws -> DocumentSnapshot
    {
        let identified = blocks.enumerated().map
        {
            IdentifiedSemanticBlock(
                blockID: FundamentalBlockID(identifier(
                    UInt64($0.offset) + 1, seed: seed
                )),
                block: $0.element
            )
        }
        let first = try #require(identified.first)
        let content = try #require(CanonicalDocumentContent(
            firstBlock: first,
            remainingBlocks: Array(identified.dropFirst())
        ))
        return DocumentSnapshot(
            generation: SnapshotGeneration(generation),
            document: CanonicalDocument(
                documentID: FundamentalDocumentID(identifier(0, seed: seed)),
                revision: DocumentRevision(revision), content: content
            )
        )
    }

    static func paragraph(_ text: String) -> SemanticBlock
    {
        .paragraph(SemanticParagraph(runs: [
            .direct(SemanticDirectRun(text: text))
        ]))
    }

    private static func identifier(_ value: UInt64, seed: UInt8) -> UUID
    {
        UUID(uuid: (
            seed, 0x26, 0x01, 0x06, 0, 0, 0, 0,
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
}
