import FundamentalParagraph
package struct NativeIndexRanges: Sendable
{
    package let ranges: [Range<Int>]

    package init(
        range: Range<Int>, indices: [Int], displayLength: Int
    ) throws
    {
        guard displayLength >= 0, range.lowerBound >= 0,
              range.upperBound <= displayLength
        else
        {
            throw ExplicitShapingFailure.nativeRange
        }
        if indices.isEmpty
        {
            guard range.isEmpty
            else
            {
                throw ExplicitShapingFailure.missingNativeIndices
            }
            ranges = []
            return
        }
        guard indices.allSatisfy({ range.contains($0) })
        else
        {
            throw ExplicitShapingFailure.nativeIndex
        }
        let logical = Set(indices).sorted()
        guard logical.first == range.lowerBound
        else
        {
            throw ExplicitShapingFailure.missingNativeIndices
        }
        var intervals: [Int: Range<Int>] = [:]
        for index in logical.indices
        {
            let upper = index + 1 < logical.count
                ? logical[index + 1] : range.upperBound
            intervals[logical[index]] = logical[index]..<upper
        }
        ranges = try indices.map
        {
            guard let interval = intervals[$0]
            else
            {
                throw ExplicitShapingFailure.nativeIndex
            }
            return interval
        }
    }
}
