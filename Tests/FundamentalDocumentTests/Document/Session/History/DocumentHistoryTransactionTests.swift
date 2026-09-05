import Testing

@testable import FundamentalDocument

extension DocumentHistoryTests
{
    @Test
    func transactionCountsBothExactCheckpoints() throws
    {
        let sequence = try HistoryTestSequence()
        let transaction = sequence.transactions[0]
        #expect(transaction.before.retainedUTF16Units == 1)
        #expect(transaction.after.retainedUTF16Units == 2)
        #expect(transaction.retainedUTF16Units == 3)
        #expect(transaction.before.snapshot == sequence.initial)
        #expect(sent(transaction) == transaction)
    }

    @Test
    func incoherentTransactionsRefuse() throws
    {
        let before = try #require(DocumentHistoryCheckpoint(
            SessionTestDocument(texts: ["A"]).editable
        ))
        let invalid = [
            try SessionTestDocument(revision: 9, generation: 4, marker: 9),
            try SessionTestDocument(revision: 8, generation: 4),
            try SessionTestDocument(revision: 10, generation: 4),
            try SessionTestDocument(revision: 9, generation: 3),
            try SessionTestDocument(revision: 9, generation: 5)
        ]
        for fixture in invalid
        {
            let after = try #require(DocumentHistoryCheckpoint(
                fixture.editable
            ))
            #expect(DocumentHistoryTransaction(before: before, after: after)
                == nil)
        }
    }
}
