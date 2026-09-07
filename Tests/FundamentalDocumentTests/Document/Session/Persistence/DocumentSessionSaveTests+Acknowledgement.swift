import Testing

@testable import FundamentalDocument

extension DocumentSessionSaveTests
{
    @Test("acknowledging an earlier snapshot never clears later typing")
    func typingDuringSave() throws
    {
        let driver = SessionHistoryTestDriver(try SessionTestDocument())
        try driver.insert("X", at: 1)
        let ticket = driver.session.prepareSave()
        try driver.insert("Y", at: 1)
        #expect(driver.session.acknowledgeSave(ticket))
        #expect(driver.session.isDirty)
        #expect(!driver.session.hasPendingSave)
        try driver.move(.undo)
        #expect(!driver.session.isDirty)
        try driver.move(.redo)
        #expect(driver.session.isDirty)
    }

    @Test("only the newest live request can acknowledge a save once")
    func requestOrderAndReplay() throws
    {
        let driver = SessionHistoryTestDriver(try SessionTestDocument())
        let older = driver.session.prepareSave()
        try driver.insert("X", at: 1)
        let newest = driver.session.prepareSave()
        #expect(!driver.session.acknowledgeSave(older))
        #expect(driver.session.isDirty)
        #expect(driver.session.hasPendingSave)
        #expect(driver.session.acknowledgeSave(newest))
        #expect(!driver.session.isDirty)
        #expect(!driver.session.acknowledgeSave(newest))
        #expect(!driver.session.acknowledgeSave(older))
    }

    @Test("identical documents in different sessions cannot share save tickets")
    func foreignSession() throws
    {
        let fixture = try SessionTestDocument()
        let first = DocumentSession(state: fixture.state)
        let second = DocumentSession(state: fixture.state)
        let a = first.prepareSave()
        let b = second.prepareSave()
        #expect(a.document == b.document)
        #expect(a.sessionID != b.sessionID)
        #expect(!first.acknowledgeSave(b))
        #expect(!second.acknowledgeSave(a))
        #expect(first.isDirty && second.isDirty)
        #expect(first.hasPendingSave && second.hasPendingSave)
        #expect(first.acknowledgeSave(a))
        #expect(second.acknowledgeSave(b))
    }
}
