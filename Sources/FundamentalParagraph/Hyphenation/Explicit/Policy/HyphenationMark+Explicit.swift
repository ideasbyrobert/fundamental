extension HyphenationMark
{
    var isExplicitBreak: Bool
    {
        self == .softHyphen || self == .asciiHyphen || self == .visibleHyphen
    }

    var inhibitsExplicitBreaks: Bool
    {
        switch self
        {
        case .nonbreakingHyphen, .wordJoiner, .zeroWidthJoiner,
             .zeroWidthNonJoiner, .zeroWidthNoBreakSpace:
            true
        default:
            false
        }
    }
}
