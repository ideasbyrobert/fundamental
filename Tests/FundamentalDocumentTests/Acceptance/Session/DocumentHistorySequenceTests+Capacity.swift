import Testing

@testable import FundamentalDocument

extension DocumentHistorySequenceTests
{
    @Test
    func evictionEstablishesAnExactUndoFloor() throws
    {
        let limits = try #require(DocumentHistoryLimits(
            transactions: 2,
            retainedUTF16Units: 100
        ))
        let driver = SessionHistoryTestDriver(
            try SessionTestDocument(texts: ["A"]),
            limits: limits
        )
        try driver.insert("B", at: 1)
        try driver.insert("C", at: 2)
        try driver.insert("D", at: 3)
        try driver.expect("ABCD", revision: 11, generation: 6)
        #expect(driver.session.history.retainedUTF16Units == 12)
        try driver.move(.undo)
        try driver.expect("ABC", revision: 12, generation: 7)
        try driver.move(.undo)
        try driver.expect("AB", revision: 13, generation: 8)
        let floor = driver.storage
        #expect(driver.session.submit(DocumentHistoryCommand(
            observation: driver.session.observation,
            direction: .undo
        )) == .refused(.historyUnavailable))
        #expect(driver.storage == floor)
        #expect(driver.session.history.retainedUTF16Units == 12)
        #expect(driver.session.history.redo.count == 2)
    }
}
