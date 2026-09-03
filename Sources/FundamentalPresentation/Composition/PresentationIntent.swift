package enum PresentationIntent: Equatable, Sendable
{
    case document
    case caret(PresentationTextPosition)
    case selection(PresentationTextSelection)
}
