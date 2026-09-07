import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingManuscriptCapacityTests
{
    @Test("empty paragraph structure is bounded independently from text units")
    func emptyParagraphLimit() throws
    {
        let maximum = WritingSurfacePolicy.maximumParagraphs
        let blocks = (0 ... maximum).map
        {
            _ in IdentifiedSemanticBlock(
                blockID: FundamentalBlockID(UUID()),
                block: .paragraph(SemanticParagraph(runs: []))
            )
        }
        let admitted = Array(blocks.prefix(maximum))
        let map = try #require(WritingParagraphMap(blocks: admitted))
        #expect(map.spans.count == maximum)
        #expect(map.utf16Count == maximum - 1)
        #expect(WritingParagraphMap(blocks: blocks) == nil)
        let document = CanonicalDocument(
            documentID: FundamentalDocumentID(UUID()), revision: .zero,
            content: try #require(CanonicalDocumentContent(
                firstBlock: admitted[0],
                remainingBlocks: Array(admitted.dropFirst())
            ))
        )
        let seed = try #require(WritingDocumentSeed(document: document))
        let projection = try #require(WritingProjection(seed.state))
        #expect(WritingTextProposal(
            ranges: [NSRange(location: 0, length: 0)],
            replacements: ["\n"], in: projection
        ) == nil)
        let replacement = try #require(WritingTextProposal(
            ranges: [NSRange(location: 0, length: 1)],
            replacements: ["\n"], in: projection
        ))
        let session = DocumentSession(state: seed.state)
        guard case .applied = session.submit(replacement.command)
        else
        {
            Issue.record("a paragraph replacement within the bound was refused")
            return
        }
        #expect(WritingProjection(session.state)?.map.spans.count == maximum)
    }
}
