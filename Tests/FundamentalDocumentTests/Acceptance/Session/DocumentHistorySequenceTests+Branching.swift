import Testing

@testable import FundamentalDocument

extension DocumentHistorySequenceTests
{
    @Test
    func acceptedBranchClearsRedoAndKeepsEarlierUndo() throws
    {
        let driver = SessionHistoryTestDriver(
            try SessionTestDocument(texts: ["A"])
        )
        try driver.insert("B", at: 1)
        try driver.insert("C", at: 2)
        try driver.move(.undo)
        #expect(driver.session.canRedo)
        try driver.insert("D", at: 2)
        try driver.expect("ABD", revision: 12, generation: 7)
        #expect(!driver.session.canRedo)
        #expect(driver.session.history.undo.count == 2)
        let branched = driver.storage
        #expect(driver.session.submit(DocumentHistoryCommand(
            observation: driver.session.observation,
            direction: .redo
        )) == .refused(.historyUnavailable))
        #expect(driver.storage == branched)
        try driver.move(.undo)
        try driver.expect("AB", revision: 13, generation: 8)
        try driver.move(.undo)
        try driver.expect("A", revision: 14, generation: 9)
        #expect(!driver.session.canUndo)
        #expect(driver.session.history.redo.count == 2)
    }
}
