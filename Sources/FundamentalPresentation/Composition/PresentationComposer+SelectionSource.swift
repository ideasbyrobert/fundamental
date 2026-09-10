extension PresentationComposer
{
    static func utf16Substring(
        _ value: String,
        range: Range<Int>
    ) -> String?
    {
        guard range.lowerBound >= 0,
              range.lowerBound < range.upperBound,
              range.upperBound <= value.utf16.count
        else
        {
            return nil
        }
        let utf16 = value.utf16
        let lowerUTF16 = utf16.index(
            utf16.startIndex,
            offsetBy: range.lowerBound
        )
        let upperUTF16 = utf16.index(
            utf16.startIndex,
            offsetBy: range.upperBound
        )
        guard let lower = String.Index(lowerUTF16, within: value),
              let upper = String.Index(upperUTF16, within: value)
        else
        {
            return nil
        }
        return String(value[lower ..< upper])
    }

    static func contiguous(
        _ slices: [PresentationSourceSlice]
    ) -> Bool
    {
        guard !slices.isEmpty
        else
        {
            return false
        }
        return zip(slices, slices.dropFirst()).allSatisfy
        {
            $0.range.upperBound == $1.range.lowerBound
                && $0.source.domain == $1.source.domain
        }
    }
}
