import Testing

@testable import FundamentalDocument

extension DocumentSessionSaveTests
{
    @Test("each edit kind leaves and restores the saved content checkpoint",
          arguments: SessionTestEdit.allCases)
    func editKinds(_ kind: SessionTestEdit) throws
    {
        let fixture = try SessionTestDocument()
        let driver = SessionHistoryTestDriver(fixture)
        let ticket = driver.session.prepareSave()
        #expect(driver.session.acknowledgeSave(ticket))
        try driver.edit(kind.edit(in: fixture))
        #expect(driver.session.isDirty)
        try driver.move(.undo)
        #expect(!driver.session.isDirty)
        #expect(driver.session.document.revision > ticket.document.revision)
        try driver.move(.redo)
        #expect(driver.session.isDirty)
    }

    @Test("saving an edit makes its redo checkpoint clean at a newer revision")
    func savedRedo() throws
    {
        let driver = SessionHistoryTestDriver(try SessionTestDocument())
        try driver.insert("X", at: 1)
        let ticket = driver.session.prepareSave()
        #expect(driver.session.acknowledgeSave(ticket))
        try driver.move(.undo)
        #expect(driver.session.isDirty)
        try driver.move(.redo)
        #expect(!driver.session.isDirty)
        #expect(driver.session.document.revision > ticket.document.revision)
    }

    @Test("branching after undo retains the saved origin before the new edit")
    func branchedHistory() throws
    {
        let driver = SessionHistoryTestDriver(try SessionTestDocument())
        try driver.insert("X", at: 1)
        let ticket = driver.session.prepareSave()
        #expect(driver.session.acknowledgeSave(ticket))
        try driver.insert("Y", at: 1)
        try driver.move(.undo)
        #expect(!driver.session.isDirty)
        try driver.insert("Z", at: 1)
        #expect(driver.session.isDirty)
        #expect(!driver.session.canRedo)
        try driver.move(.undo)
        #expect(!driver.session.isDirty)
        try driver.move(.redo)
        #expect(driver.session.isDirty)
    }
}
