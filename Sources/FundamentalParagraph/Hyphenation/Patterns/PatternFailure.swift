package enum PatternFailure: Error, Equatable, Sendable
{
    case invalidPattern(String)
    case invalidException(String)
    case invalidDocument
    case conflictingException(String)
    case invalidMinima
    case invalidWord
    case invalidEncoding
    case checksumMismatch
    case invalidResource
}
