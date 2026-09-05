import Testing

@testable import FundamentalDocument

extension DocumentSessionHistoryTests
{
    @Test
    func readableSessionRefusesHistoryDirections() throws
    {
        let fixture = try SessionTestDocument()
        let state = DocumentSessionState.readable(fixture.editable.snapshot)
        let session = DocumentSession(state: state)
        for direction in [DocumentHistoryDirection.undo, .redo]
        {
            #expect(session.submit(DocumentHistoryCommand(
                observation: session.observation,
                direction: direction
            )) == .refused(.readOnly))
        }
        #expect(session.state == state)
        #expect(session.history == DocumentHistory())
    }

    @Test
    func unavailableHistoryConsumesNothing() throws
    {
        let driver = SessionHistoryTestDriver(try SessionTestDocument())
        let initial = driver.storage
        for direction in [DocumentHistoryDirection.undo, .redo]
        {
            #expect(driver.session.submit(DocumentHistoryCommand(
                observation: driver.session.observation,
                direction: direction
            )) == .refused(.historyUnavailable))
            #expect(driver.storage == initial)
        }
    }
}
