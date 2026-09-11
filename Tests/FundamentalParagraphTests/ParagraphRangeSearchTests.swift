@testable import FundamentalParagraph
import FundamentalNativeParagraph
import Testing

@Suite
struct ParagraphRangeSearchTests
{
    static let samples: [[Range<Int>]] = [
        [], [0..<4], [0..<2, 2..<4, 4..<6],
        [1..<3, 5..<7, 9..<12], [2..<3, 8..<9]
    ]

    @Test(arguments: samples)
    func matchesAnIndependentLinearOracle(_ ranges: [Range<Int>])
    {
        for lower in -1...12
        {
            for upper in lower...13
            {
                let query = lower..<upper
                var reads = 0
                let result = ParagraphRangeSearch.intersecting(
                    query, count: ranges.count
                )
                {
                    reads += 1
                    return ranges[$0]
                }
                let expected = ranges.indices.filter
                {
                    !query.isEmpty && ranges[$0].lowerBound < upper
                        && ranges[$0].upperBound > lower
                }
                #expect(Array(result.indices) == Array(expected))
                #expect(result.comparisons == reads)
            }
        }
    }

    @Test(arguments: [1, 64, 4096, 65536])
    func largeLogicalIndexesUseBoundedReads(_ count: Int) throws
    {
        let start = (count - 1) * 3
        var reads = 0
        let result = ParagraphRangeSearch.intersecting(
            start..<(start + 1), count: count
        )
        {
            reads += 1
            return ($0 * 3)..<($0 * 3 + 2)
        }
        let limit = 2 * (Int.bitWidth - count.leadingZeroBitCount)
        #expect(result.indices == (count - 1)..<count)
        #expect(result.comparisons == reads)
        #expect(reads <= limit)
        try RangeEvidence.record("logical-\(count)", values: [
            "intervalCount": count, "reads": reads, "readLimit": limit,
            "matchingIntervals": result.indices.count
        ])
    }
}
