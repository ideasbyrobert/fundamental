package struct ParagraphSpacing: Equatable, Sendable
{
    package enum Kind: String, Sendable
    {
        case natural
        case justified
        case ragged
    }

    package let kind: Kind
    package let adjustment: Double
    package let advance: Double
    package let ratio: Double
    package let fitness: ParagraphFitness

    package var ragged: Int
    {
        kind == .ragged ? 1 : 0
    }

    package var badness: Double
    {
        let magnitude = abs(ratio)
        return 100 * magnitude * magnitude * magnitude
    }
}
