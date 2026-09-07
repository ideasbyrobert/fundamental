import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalStorage

extension DocumentFileFixture
{
    static func document(
        _ text: String = "A first paragraph.",
        revision: UInt64 = 1,
        identity: UUID? = nil
    ) throws -> CanonicalDocument
    {
        let original = try codec.decode(record)
        let first = try #require(original.content.blocks.first)
        let paragraph = SemanticParagraph(runs: [SemanticRun(text: text)])
        let block = IdentifiedSemanticBlock(
            blockID: first.blockID,
            block: .paragraph(paragraph)
        )
        let content = try #require(CanonicalDocumentContent(
            firstBlock: block, remainingBlocks: []
        ))
        return CanonicalDocument(
            documentID: identity.map(FundamentalDocumentID.init)
                ?? original.documentID,
            revision: DocumentRevision(revision),
            content: content
        )
    }

    static func writer(
        at location: DocumentFileLocation,
        condition: DocumentFileWriteCondition = .absent
    ) throws -> DocumentFileWriter
    {
        DocumentFileWriter(
            document: try document(),
            location: location,
            condition: condition,
            codec: codec
        )
    }
}
