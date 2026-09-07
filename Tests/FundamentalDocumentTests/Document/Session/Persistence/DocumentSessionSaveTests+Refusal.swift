import Testing

@testable import FundamentalDocument

extension DocumentSessionSaveTests
{
    @Test("history refusal never advances the saved content origin")
    func capacityRefusal() throws
    {
        let fixture = try SessionTestDocument()
        let limits = try #require(DocumentHistoryLimits(
            transactions: 1, retainedUTF16Units: 1
        ))
        let driver = SessionHistoryTestDriver(fixture, limits: limits)
        #expect(driver.session.acknowledgeSave(driver.session.prepareSave()))
        let ticket = driver.session.prepareSave()
        let result = driver.session.submit(.edit(
            driver.session.observation,
            try SessionTestEdit.insertion.edit(in: fixture)
        ))
        #expect(result == .refused(.historyCapacity))
        #expect(!driver.session.isDirty)
        #expect(driver.session.document == ticket.document)
        #expect(driver.session.acknowledgeSave(ticket))
    }

    @Test("evicted history cannot manufacture a return to an older saved point")
    func evictedCheckpoint() throws
    {
        let limits = try #require(DocumentHistoryLimits(
            transactions: 1, retainedUTF16Units: 100
        ))
        let driver = SessionHistoryTestDriver(
            try SessionTestDocument(), limits: limits
        )
        #expect(driver.session.acknowledgeSave(driver.session.prepareSave()))
        try driver.insert("X", at: 1)
        try driver.insert("Y", at: 1)
        try driver.move(.undo)
        #expect(driver.session.isDirty)
        #expect(!driver.session.canUndo)
        #expect(driver.session.acknowledgeSave(driver.session.prepareSave()))
        #expect(!driver.session.isDirty)
    }
}
