import FundamentalWrapping

package struct ParagraphHyphenationMarks: Sendable
{
    package let marks: [SourceHyphenationMark]
    package let sourceLength: Int

    package init(_ source: WrappingSource)
    {
        var marks: [SourceHyphenationMark] = []
        var offset = 0
        for scalar in source.text.unicodeScalars
        {
            let end = offset + scalar.utf16.count
            if let mark = HyphenationMark(rawValue: scalar.value)
            {
                marks.append(.init(mark: mark, range: offset..<end))
            }
            offset = end
        }
        self.marks = marks
        sourceLength = offset
    }

    package func touching(_ range: Range<Int>) -> [SourceHyphenationMark]
    {
        let lower = max(0, range.lowerBound - 1)
        let upper = range.upperBound < sourceLength
            ? range.upperBound + 1 : sourceLength
        let found = ParagraphRangeSearch.intersecting(
            lower..<upper, count: marks.count
        )
        {
            marks[$0].range
        }
        return Array(marks[found.indices])
    }
}
