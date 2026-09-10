package enum WrappingLineEnding: Equatable, Hashable, Sendable
{
    case lineFeed
    case carriageReturn
    case carriageReturnLineFeed
    case nextLine
    case verticalTab
    case formFeed
    case lineSeparator
    case paragraphSeparator

    init?(_ character: Character)
    {
        switch character
        {
        case "\n":
            self = .lineFeed
        case "\r":
            self = .carriageReturn
        case "\r\n":
            self = .carriageReturnLineFeed
        case "\u{85}":
            self = .nextLine
        case "\u{B}":
            self = .verticalTab
        case "\u{C}":
            self = .formFeed
        case "\u{2028}":
            self = .lineSeparator
        case "\u{2029}":
            self = .paragraphSeparator
        default:
            return nil
        }
    }
}
