import Foundation
@testable import FundamentalDocument
import FundamentalParagraph
import Testing

@MainActor
enum ParagraphSessionFixture
{
    static func session(_ runs: [SemanticRun]) throws -> DocumentSession
    {
        let block = IdentifiedSemanticBlock(
            blockID: FundamentalBlockID(UUID()),
            block: .paragraph(SemanticParagraph(runs: runs))
        )
        let document = CanonicalDocument(
            documentID: FundamentalDocumentID(UUID()),
            revision: DocumentRevision(7),
            content: try #require(CanonicalDocumentContent(
                firstBlock: block, remainingBlocks: []
            ))
        )
        let point = DocumentPoint(
            documentID: document.documentID, revision: document.revision,
            blockID: block.blockID,
            utf16Offset: try #require(DocumentUTF16Offset(0))
        )
        let editable = try #require(EditableDocumentSnapshot(
            snapshot: DocumentSnapshot(
                generation: SnapshotGeneration(9), document: document
            ),
            selection: .caret(at: point)
        ))
        return DocumentSession(state: .editable(editable), initiallySaved: true)
    }

    static func source(_ session: DocumentSession) throws -> ParagraphWordSource
    {
        guard case let .paragraph(paragraph) =
            session.document.content.firstBlock.block
        else
        {
            throw WordFixtureFailure.invalidValue
        }
        return try WordFixture.source(paragraph.runs)
    }
}
