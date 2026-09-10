extension WrappingSource
{
    package func isBoundary(_ offset: Int) -> Bool
    {
        guard offset >= 0, offset <= utf16.count
        else
        {
            return false
        }
        var lower = 0
        var upper = graphemeBoundaries.count
        while lower < upper
        {
            let middle = lower + (upper - lower) / 2
            let boundary = graphemeBoundaries[middle]
            if boundary == offset
            {
                return true
            }
            if boundary < offset
            {
                lower = middle + 1
            }
            else
            {
                upper = middle
            }
        }
        return false
    }

    package func range(location: Int, length: Int) -> Range<Int>?
    {
        guard location >= 0, length >= 0, location <= utf16.count,
              length <= utf16.count - location
        else
        {
            return nil
        }
        let end = location + length
        guard isBoundary(location), isBoundary(end)
        else
        {
            return nil
        }
        return location ..< end
    }

    package func substring(in range: Range<Int>) -> String?
    {
        guard isBoundary(range.lowerBound), isBoundary(range.upperBound)
        else
        {
            return nil
        }
        return String(decoding: utf16[range], as: UTF16.self)
    }
}
