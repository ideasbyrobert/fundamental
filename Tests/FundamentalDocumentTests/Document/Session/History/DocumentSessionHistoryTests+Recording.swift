import Testing

@testable import FundamentalDocument

extension DocumentSessionHistoryTests
{
    @Test
    func selectionChangesNeverRecordOrClearHistory() throws
    {
        let driver = SessionHistoryTestDriver(try SessionTestDocument())
        try driver.insert("X", at: 1)
        try driver.move(.undo)
        let retained = driver.session.history
        let selected = try driver.select(3, 1)
        #expect(driver.session.history == retained)
        #expect(driver.session.submit(.select(
            driver.session.observation,
            selected.selection
        )) == .unchanged)
        #expect(driver.session.history == retained)
        #expect(driver.session.canRedo)
    }

    @Test(arguments: SessionTestEdit.allCases)
    func eachAdmittedEditRecordsExactlyOneTransaction(
        _ kind: SessionTestEdit
    ) throws
    {
        let fixture = try SessionTestDocument()
        let driver = SessionHistoryTestDriver(fixture)
        let after = try driver.edit(kind.edit(in: fixture))
        #expect(driver.session.history.undo.count == 1)
        #expect(driver.session.history.redo.isEmpty)
        let transaction = try #require(driver.session.history.undo.first)
        #expect(transaction.before.snapshot == fixture.editable)
        #expect(transaction.after.snapshot == after)
        #expect(driver.session.canUndo)
        #expect(!driver.session.canRedo)
    }
}
