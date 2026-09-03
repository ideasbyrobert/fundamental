import Testing

@testable import FundamentalDocument

extension DocumentSessionStateTests
{
    static func snapshot(
        generation: UInt64 = 3,
        revision: UInt64 = 8
    ) throws -> DocumentSnapshot
    {
        try snapshot(
            generation: generation,
            revision: revision,
            block: DocumentSnapshotTests.editableBlock(.paragraph)
        )
    }

    static func snapshot(
        generation: UInt64 = 3,
        revision: UInt64 = 8,
        block: SemanticBlock
    ) throws -> DocumentSnapshot
    {
        try DocumentSnapshotTests.snapshot(
            generation: generation,
            revision: revision,
            blocks: [(2, block)]
        )
    }

    static func selection(
        revision: UInt64 = 8,
        endOffset: Int = 0
    ) throws -> DocumentSelection
    {
        try DocumentSnapshotTests.selection(
            revision: revision,
            endOffset: endOffset
        )
    }

    static func editableState(
        generation: UInt64 = 3,
        revision: UInt64 = 8,
        form: EditableDocumentBlockForm = .paragraph,
        endOffset: Int = 0
    ) throws -> DocumentSessionState
    {
        let snapshot = try Self.snapshot(
            generation: generation,
            revision: revision,
            block: DocumentSnapshotTests.editableBlock(form)
        )
        let selection = try Self.selection(
            revision: revision,
            endOffset: endOffset
        )
        let editable = try #require(EditableDocumentSnapshot(
            snapshot: snapshot,
            selection: selection
        ))
        return .editable(editable)
    }

    static func requireSendable<T: Sendable>(_ type: T.Type)
    {
    }
}
