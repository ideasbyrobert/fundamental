import Testing

@testable import FundamentalDocument

enum SessionTestEdit: CaseIterable
{
    case insertion
    case deletion
    case replacement
    case split
    case merge

    func edit(in fixture: SessionTestDocument) throws -> CanonicalDocumentEdit
    {
        let insertion = try #require(SemanticInsertion(
            text: "X",
            attributes: .direct(traits: [.strong])
        ))
        let range = try fixture.selection(1, 3).range
        switch self
        {
        case .insertion:
            return .text(.insertion(SemanticTextInsertion(
                point: try fixture.point(1),
                insertion: insertion
            )))
        case .deletion:
            return .text(.deletion(try #require(SemanticTextDeletion(
                range: range
            ))))
        case .replacement:
            return .text(.replacement(try #require(SemanticTextReplacement(
                range: range,
                insertion: insertion
            ))))
        case .split:
            return .split(try #require(SemanticBlockSplit(
                point: fixture.point(2),
                continuationBlockID: FundamentalBlockID(
                    SessionTestDocument.identity(4)
                )
            )))
        case .merge:
            let source = fixture.editable.snapshot.document
            return .merge(try #require(SemanticBlockMerge(
                documentID: source.documentID,
                revision: source.revision,
                leadingBlockID: source.content.blocks[0].blockID,
                trailingBlockID: source.content.blocks[1].blockID
            )))
        }
    }

    static func inserted(
        _ text: String,
        at point: DocumentPoint
    ) throws -> CanonicalDocumentEdit
    {
        .text(.insertion(SemanticTextInsertion(
            point: point,
            insertion: try #require(SemanticInsertion(
                text: text,
                attributes: .direct(traits: [])
            ))
        )))
    }
}
