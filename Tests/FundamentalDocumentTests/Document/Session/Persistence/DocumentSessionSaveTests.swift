import Testing

@testable import FundamentalDocument

@Suite("Canonical saved content ownership")
@MainActor
struct DocumentSessionSaveTests
{
    @Test("new and opened sessions state their initial persistence explicitly")
    func initialState() throws
    {
        let fixture = try SessionTestDocument()
        for state in [fixture.state, .readable(fixture.editable.snapshot)]
        {
            let fresh = DocumentSession(state: state)
            let opened = DocumentSession(state: state, initiallySaved: true)
            #expect(fresh.isDirty)
            #expect(!opened.isDirty)
            #expect(!fresh.hasPendingSave)
            #expect(!opened.hasPendingSave)
            #expect(fresh.document == fixture.editable.snapshot.document)
            #expect(opened.state == state)
        }
    }

    @Test("preparing a save retains an immutable canonical snapshot")
    func preparedSnapshot() throws
    {
        let fixture = try SessionTestDocument()
        let driver = SessionHistoryTestDriver(fixture)
        let ticket = driver.session.prepareSave()
        #expect(driver.session.hasPendingSave)
        #expect(driver.session.isDirty)
        try driver.insert("X", at: 1)
        #expect(ticket.document == fixture.editable.snapshot.document)
        #expect(driver.session.document != ticket.document)
        #expect(ticket.contentRevision == ticket.document.revision)
    }

    @Test("selection alone changes neither saved content nor a pending ticket")
    func selection() throws
    {
        let driver = SessionHistoryTestDriver(try SessionTestDocument())
        let first = driver.session.prepareSave()
        #expect(driver.session.acknowledgeSave(first))
        let pending = driver.session.prepareSave()
        try driver.select(3, 1)
        #expect(!driver.session.isDirty)
        #expect(driver.session.hasPendingSave)
        #expect(driver.session.acknowledgeSave(pending))
        #expect(!driver.session.isDirty)
    }
}
