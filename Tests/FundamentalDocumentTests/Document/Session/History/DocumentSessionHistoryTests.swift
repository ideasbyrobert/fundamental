import Testing

@testable import FundamentalDocument

@Suite("Canonical session history ownership")
@MainActor
struct DocumentSessionHistoryTests
{
    @Test
    func historyCommandsRequireObservationAndDirection() throws
    {
        let observation = try SessionTestDocument().observation
        let undo = DocumentHistoryCommand(observation: observation,
                                          direction: .undo)
        let redo = DocumentHistoryCommand(observation: observation,
                                          direction: .redo)
        #expect(undo.observation == observation)
        #expect(undo.direction == .undo)
        #expect(redo.direction == .redo)
        #expect(undo != redo)
        #expect(sent(undo) == undo)
    }

    @Test
    func standardAndExplicitHistoryLimitsRemainRequired() throws
    {
        let fixture = try SessionTestDocument()
        let standard = DocumentSession(state: fixture.state)
        #expect(standard.history.limits == DocumentHistoryLimits())
        let limits = try #require(DocumentHistoryLimits(
            transactions: 2,
            retainedUTF16Units: 10
        ))
        let explicit = DocumentSession(state: fixture.state,
                                       historyLimits: limits)
        #expect(explicit.history.limits == limits)
        #expect(explicit.state == fixture.state)
    }

    @Test
    func initializationPublishesNoHistoryOrCounterChange() throws
    {
        let fixture = try SessionTestDocument()
        let driver = SessionHistoryTestDriver(fixture)
        #expect(driver.storage.state == fixture.state)
        #expect(driver.session.observation == fixture.observation)
        #expect(driver.storage.history == DocumentHistory())
        #expect(!driver.session.canUndo)
        #expect(!driver.session.canRedo)
        #expect(sent(driver.storage) == driver.storage)
    }

    func sent<Value: Sendable>(_ value: Value) -> Value
    {
        value
    }
}
