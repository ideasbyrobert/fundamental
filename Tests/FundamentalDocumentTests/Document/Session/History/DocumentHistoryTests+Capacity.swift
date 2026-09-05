import Testing

@testable import FundamentalDocument

extension DocumentHistoryTests
{
    @Test
    func countCapacityEvictsOldestUndo() throws
    {
        let sequence = try HistoryTestSequence()
        let limits = try #require(DocumentHistoryLimits(
            transactions: 2,
            retainedUTF16Units: 100
        ))
        let history = try sequence.history(limits: limits)
        #expect(history.undo == Array(sequence.transactions.suffix(2)))
        #expect(history.redo.isEmpty)
        #expect(history.retainedUTF16Units == 12)
        #expect(sent(history) == history)
    }

    @Test
    func UTF16CapacityAdmitsEqualityAndEvictsUntilBounded() throws
    {
        let sequence = try HistoryTestSequence()
        let limits = try #require(DocumentHistoryLimits(
            transactions: 64,
            retainedUTF16Units: 8
        ))
        let first = try #require(DocumentHistory(
            recording: sequence.transactions[0],
            in: DocumentHistory(limits: limits)
        ))
        let second = try #require(DocumentHistory(
            recording: sequence.transactions[1],
            in: first
        ))
        #expect(second.retainedUTF16Units == 8)
        let third = try #require(DocumentHistory(
            recording: sequence.transactions[2],
            in: second
        ))
        #expect(third.undo == [sequence.transactions[2]])
        #expect(third.retainedUTF16Units == 7)
        #expect(first.retainedUTF16Units == 3)
        #expect(second.undo.count == 2)
    }

    @Test
    func zeroTextTransactionsStillConsumeCount() throws
    {
        let states = try (0...2).map
        {
            index in
            try SessionTestDocument(
                texts: Array(repeating: "", count: index + 1),
                revision: UInt64(index + 8),
                generation: UInt64(index + 3)
            ).editable
        }
        let first = try HistoryTestSequence.transaction(states[0], states[1])
        let second = try HistoryTestSequence.transaction(states[1], states[2])
        let limits = try #require(DocumentHistoryLimits(
            transactions: 1,
            retainedUTF16Units: 1
        ))
        let one = try #require(DocumentHistory(
            recording: first,
            in: DocumentHistory(limits: limits)
        ))
        let two = try #require(DocumentHistory(recording: second, in: one))
        #expect(two.undo == [second])
        #expect(two.retainedUTF16Units == 0)
        #expect(one.undo == [first])
    }
}
