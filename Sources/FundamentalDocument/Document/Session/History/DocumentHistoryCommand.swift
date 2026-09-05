struct DocumentHistoryCommand: Equatable, Sendable
{
    let observation: DocumentObservation
    let direction: DocumentHistoryDirection
}
