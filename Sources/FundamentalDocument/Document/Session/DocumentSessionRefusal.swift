enum DocumentSessionRefusal: Equatable, Sendable
{
    case staleObservation
    case readOnly
    case invalidCommand
    case generationExhausted
    case historyUnavailable
    case historyCapacity
}
