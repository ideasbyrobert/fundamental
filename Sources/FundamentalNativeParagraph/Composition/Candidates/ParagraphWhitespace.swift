enum ParagraphWhitespace
{
    static func contains(_ unit: UInt16) -> Bool
    {
        unit == 32 || unit == 9
    }

    static func contains(_ range: Range<Int>, units: [UInt16]) -> Bool
    {
        range.count == 1 && contains(units[range.lowerBound])
    }
}
