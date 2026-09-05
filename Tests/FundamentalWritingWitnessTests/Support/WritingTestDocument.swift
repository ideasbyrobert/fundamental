import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

struct WritingTestDocument
{
    let state: DocumentSessionState

    init(_ text: String = "") throws
    {
        try self.init(blocks: [
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: text)]))
        ])
    }

    init(
        blocks: [SemanticBlock],
        start: Int = 0,
        end: Int = 0
    ) throws
    {
        let identified = blocks.enumerated().map
        {
            index, block in
            IdentifiedSemanticBlock(
                blockID: FundamentalBlockID(Self.identity(UInt8(index + 2))),
                block: block
            )
        }
        let first = try #require(identified.first)
        let content = try #require(CanonicalDocumentContent(
            firstBlock: first,
            remainingBlocks: Array(identified.dropFirst())
        ))
        let document = CanonicalDocument(
            documentID: FundamentalDocumentID(Self.identity(1)),
            revision: DocumentRevision(8),
            content: content
        )
        let snapshot = DocumentSnapshot(
            generation: SnapshotGeneration(3),
            document: document
        )
        guard blocks.allSatisfy({ EditableSemanticBlock($0) != nil })
        else
        {
            state = .readable(snapshot)
            return
        }
        let lower = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: first.blockID,
            utf16Offset: try #require(DocumentUTF16Offset(start))
        )
        let upper = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: first.blockID,
            utf16Offset: try #require(DocumentUTF16Offset(end))
        )
        let range = try #require(DocumentRange(start: lower, end: upper))
        state = .editable(try #require(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: DocumentSelection(range: range)
        )))
    }

    func projection() throws -> WritingProjection
    {
        try #require(WritingProjection(state))
    }

    static func identity(_ marker: UInt8) -> UUID
    {
        UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, marker))
    }
}
