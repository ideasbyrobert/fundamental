@testable import FundamentalParagraph
import FundamentalNativeParagraph
enum LinearWordOracle
{
    static func fragments(
        in range: Range<Int>, source: ParagraphWordSource
    ) -> (values: [WordRunFragment], reads: Int)
    {
        var values: [WordRunFragment] = []
        var reads = 0
        for span in source.spans
        {
            reads += 1
            let lower = max(span.range.lowerBound, range.lowerBound)
            let upper = min(span.range.upperBound, range.upperBound)
            if lower < upper
            {
                let start = lower - span.range.lowerBound
                values.append(WordRunFragment(
                    runIndex: span.index, paragraphRange: lower..<upper,
                    runRange: start..<(start + upper - lower)
                ))
            }
        }
        return (values, reads)
    }

    static func endings(
        in range: Range<Int>, source: ParagraphWordSource
    ) -> (values: [Range<Int>], reads: Int)
    {
        var values: [Range<Int>] = []
        var reads = 0
        for line in source.source.lines
        {
            reads += 1
            let ending = line.endingRange
            if !ending.isEmpty, ending.overlaps(range)
            {
                values.append(ending)
            }
        }
        return (values, reads)
    }
}
