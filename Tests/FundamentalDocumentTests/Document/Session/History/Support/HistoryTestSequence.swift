import Testing

@testable import FundamentalDocument

struct HistoryTestSequence
{
    let initial: EditableDocumentSnapshot
    let transactions: [DocumentHistoryTransaction]

    init() throws
    {
        initial = try SessionTestDocument(texts: ["A"]).editable
        var state = initial
        var admitted: [DocumentHistoryTransaction] = []
        for text in ["B", "C", "D"]
        {
            let document = state.snapshot.document
            let point = DocumentPoint(
                documentID: document.documentID,
                revision: document.revision,
                blockID: document.content.firstBlock.blockID,
                utf16Offset: try #require(DocumentUTF16Offset(
                    admitted.count + 1
                ))
            )
            let result = DocumentSessionTransition(.edit(
                DocumentObservation(snapshot: state.snapshot),
                try SessionTestEdit.inserted(text, at: point)
            ), in: .editable(state))
            guard case let .applied(.editable(successor)) = result
            else
            {
                throw SessionTestFailure.expectedEditable
            }
            admitted.append(try Self.transaction(state, successor))
            state = successor
        }
        transactions = admitted
    }

    func history(
        limits: DocumentHistoryLimits = DocumentHistoryLimits()
    ) throws -> DocumentHistory
    {
        var history = DocumentHistory(limits: limits)
        for transaction in transactions
        {
            history = try #require(DocumentHistory(
                recording: transaction,
                in: history
            ))
        }
        return history
    }

    static func transaction(
        _ before: EditableDocumentSnapshot,
        _ after: EditableDocumentSnapshot
    ) throws -> DocumentHistoryTransaction
    {
        let first = try #require(DocumentHistoryCheckpoint(before))
        let last = try #require(DocumentHistoryCheckpoint(after))
        return try #require(DocumentHistoryTransaction(
            before: first,
            after: last
        ))
    }
}
