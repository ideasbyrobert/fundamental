package enum WrappingLineBreak: Equatable, Hashable, Sendable
{
    case soft
    case emergency
    case hard(WrappingLineEnding)
    case end
}
