package struct DocumentHistoryCommand: Equatable, Sendable
{
    let observation: DocumentObservation
    let direction: DocumentHistoryDirection

    package init(
        observation: DocumentObservation,
        direction: DocumentHistoryDirection
    )
    {
        self.observation = observation
        self.direction = direction
    }
}
