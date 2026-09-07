import Foundation
import Testing

@testable import FundamentalDocument

struct SemanticWritingTestDocument
{
    let document: CanonicalDocument

    init(
        _ styles: [CanonicalBlockStyle], texts: [String]? = nil,
        revision: UInt64 = 8
    ) throws
    {
        document = try DocumentRecordTestValue.document(
            blocks: styles.enumerated().map
            {
                $0.element.semanticBlock(runs: [SemanticRun(
                    text: texts?[$0.offset] ?? "ABCD"
                )])
            },
            revision: revision
        )
    }

    func point(_ block: Int, _ offset: Int) throws -> DocumentPoint
    {
        DocumentPoint(
            documentID: document.documentID, revision: document.revision,
            blockID: document.content.blocks[block].blockID,
            utf16Offset: try #require(DocumentUTF16Offset(offset))
        )
    }

    func range(_ start: (Int, Int), _ end: (Int, Int)) throws -> DocumentRange
    {
        try #require(DocumentRange(
            start: point(start.0, start.1), end: point(end.0, end.1)
        ))
    }

    func state(
        _ range: DocumentRange? = nil, generation: UInt64 = 3
    ) throws -> DocumentSessionState
    {
        let range = try range ?? self.range((0, 0), (0, 0))
        return .editable(try #require(EditableDocumentSnapshot(
            snapshot: DocumentSnapshot(
                generation: SnapshotGeneration(generation), document: document
            ),
            selection: DocumentSelection(range: range)
        )))
    }

    func replacement(
        _ start: (Int, Int), _ end: (Int, Int), text: [String]
    ) throws -> SemanticParagraphReplacement
    {
        try #require(SemanticParagraphReplacement(
            range: range(start, end),
            paragraphs: text.map
            {
                SemanticParagraph(
                    runs: $0.isEmpty ? [] : [SemanticRun(text: $0)]
                )
            },
            continuationBlockIDs: text.dropFirst().map
            {
                _ in FundamentalBlockID(UUID())
            }
        ))
    }

    static func texts(_ document: CanonicalDocument) -> [String]
    {
        document.content.blocks.map
        {
            EditableSemanticBlock($0.block)?.runs.map(\.text).joined() ?? "?"
        }
    }
}
