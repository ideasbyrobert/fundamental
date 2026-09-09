extension CodeConversionLines
{
    static func ranges(in units: [UInt16]) -> [Range<Int>]
    {
        var ranges: [Range<Int>] = []
        var start = 0
        var index = 0
        while index < units.count
        {
            let unit = units[index]
            guard unit == 0x0D || unit == 0x0A
            else
            {
                index += 1
                continue
            }
            ranges.append(start ..< index)
            index += 1
            if unit == 0x0D, index < units.count, units[index] == 0x0A
            {
                index += 1
            }
            start = index
        }
        ranges.append(start ..< units.count)
        return ranges
    }
}
