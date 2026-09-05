import Foundation
import Testing

@testable import FundamentalDocument

struct SessionTestDocument
{
    let editable: EditableDocumentSnapshot

    init(
        texts: [String] = ["ABCD", "EF"],
        revision: UInt64 = 8,
        generation: UInt64 = 3,
        marker: UInt8 = 1
    ) throws
    {
        let blocks = texts.enumerated().map
        {
            index, text in
            IdentifiedSemanticBlock(
                blockID: FundamentalBlockID(Self.identity(UInt8(index + 2))),
                block: .paragraph(SemanticParagraph(
                    runs: [SemanticRun(text: text)]
                ))
            )
        }
        let first = try #require(blocks.first)
        let content = try #require(CanonicalDocumentContent(
            firstBlock: first,
            remainingBlocks: Array(blocks.dropFirst())
        ))
        let document = CanonicalDocument(
            documentID: FundamentalDocumentID(Self.identity(marker)),
            revision: DocumentRevision(revision),
            content: content
        )
        let point = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: first.blockID,
            utf16Offset: try #require(DocumentUTF16Offset(0))
        )
        editable = try #require(EditableDocumentSnapshot(
            snapshot: DocumentSnapshot(
                generation: SnapshotGeneration(generation),
                document: document
            ),
            selection: .caret(at: point)
        ))
    }

    var state: DocumentSessionState
    {
        .editable(editable)
    }

    var observation: DocumentObservation
    {
        DocumentObservation(snapshot: editable.snapshot)
    }

    func point(_ offset: Int, block: Int = 0) throws -> DocumentPoint
    {
        let document = editable.snapshot.document
        return DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: document.content.blocks[block].blockID,
            utf16Offset: try #require(DocumentUTF16Offset(offset))
        )
    }

    func selection(_ start: Int, _ end: Int) throws -> DocumentSelection
    {
        DocumentSelection(range: try #require(DocumentRange(
            start: point(start),
            end: point(end)
        )))
    }

    static func identity(_ marker: UInt8) -> UUID
    {
        UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, marker))
    }
}
