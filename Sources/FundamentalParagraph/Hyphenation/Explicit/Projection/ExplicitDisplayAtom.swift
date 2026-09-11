package struct ExplicitDisplayAtom: Equatable, Sendable
{
    package enum Kind: String, Sendable
    {
        case source
        case suppressedSoftHyphen
        case conditionalHyphen
    }

    package let fragment: WordRunFragment
    package let kind: Kind
}
