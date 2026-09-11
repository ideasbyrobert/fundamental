import FundamentalParagraph
package enum ParagraphBreakKind: Sendable
{
    case start
    case space
    case authored(ExplicitBreakSelection, conditional: Bool)
    case automatic(AutomaticSelection)
    case emergency
    case terminal(ParagraphTerminal)

    package var rank: Int
    {
        switch self
        {
        case .start: 0
        case .space: 1
        case .authored: 2
        case .automatic: 3
        case .emergency: 4
        case .terminal: 5
        }
    }

    package var displayEnd: HyphenatedLineEnd
    {
        switch self
        {
        case let .authored(selection, _): .explicit(selection)
        case let .automatic(selection): .automatic(selection)
        default: .unbroken
        }
    }
}
