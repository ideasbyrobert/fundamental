import Testing

@testable import FundamentalDocument

extension DocumentHistoryTests
{
    @Test
    func admittedRecordingDiscardsRedoOnlyInSuccessor() throws
    {
        let sequence = try HistoryTestSequence()
        let original = try sequence.history()
        let undone = try #require(DocumentHistory(moving: .undo, in: original))
        let branch = try #require(DocumentHistory(
            recording: sequence.transactions[2],
            in: undone
        ))
        #expect(branch.undo == sequence.transactions)
        #expect(branch.redo.isEmpty)
        #expect(undone.redo == [sequence.transactions[2]])
        #expect(original.undo == sequence.transactions)
    }

    @Test
    func oversizedRecordingRefusesWithoutDestroyingRedo() throws
    {
        let sequence = try HistoryTestSequence()
        let limits = try #require(DocumentHistoryLimits(
            transactions: 64,
            retainedUTF16Units: 3
        ))
        let recorded = try #require(DocumentHistory(
            recording: sequence.transactions[0],
            in: DocumentHistory(limits: limits)
        ))
        let undone = try #require(DocumentHistory(moving: .undo, in: recorded))
        #expect(DocumentHistory(recording: sequence.transactions[1],
                                in: undone) == nil)
        #expect(undone.undo.isEmpty)
        #expect(undone.redo == [sequence.transactions[0]])
        #expect(undone.retainedUTF16Units == 3)
    }
}
