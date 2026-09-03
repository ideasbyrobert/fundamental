package struct ProjectedUTF16Range: Equatable, Sendable
{
    package let value: Range<Int>

    init(_ value: Range<Int>)
    {
        self.value = value
    }

    package var lowerBound: Int
    {
        value.lowerBound
    }

    package var upperBound: Int
    {
        value.upperBound
    }
}
