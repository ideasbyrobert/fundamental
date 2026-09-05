import Testing

@testable import FundamentalDocument

extension DocumentHistoryTests
{
    @Test
    func movementTransfersExactTransactionsWithoutChangingRetention() throws
    {
        let sequence = try HistoryTestSequence()
        let original = try sequence.history()
        let undone = try #require(DocumentHistory(moving: .undo, in: original))
        #expect(undone.undo == Array(sequence.transactions.prefix(2)))
        #expect(undone.redo == [sequence.transactions[2]])
        #expect(undone.retainedUTF16Units == original.retainedUTF16Units)
        let redone = try #require(DocumentHistory(moving: .redo, in: undone))
        #expect(redone == original)
        let directions: [DocumentHistoryDirection] = [.undo, .redo]
        #expect(directions.map
        {
            switch $0
            {
            case .undo:
                "undo"
            case .redo:
                "redo"
            }
        } == ["undo", "redo"])
        #expect(sent(directions) == directions)
    }
}
