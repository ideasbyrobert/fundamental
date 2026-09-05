enum DocumentSessionRefusal: Equatable, Sendable
{
    case staleObservation
    case readOnly
    case invalidCommand
    case generationExhausted
}
