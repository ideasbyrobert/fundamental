package enum HyphenationMark: UInt32, CaseIterable, Sendable
{
    case asciiHyphen = 0x2D
    case visibleHyphen = 0x2010
    case softHyphen = 0xAD
    case nonbreakingHyphen = 0x2011
    case wordJoiner = 0x2060
    case zeroWidthJoiner = 0x200D
    case zeroWidthNonJoiner = 0x200C
    case zeroWidthNoBreakSpace = 0xFEFF
    case apostrophe = 0x27
    case rightQuotationMark = 0x2019
}
