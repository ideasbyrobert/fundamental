import FundamentalWrapping

package struct ParagraphBreakSet: Sendable
{
    package let line: WrappingSourceLine
    package let breaks: [ParagraphBreak]

    init(_ collection: ParagraphHyphens, line: WrappingSourceLine) throws
    {
        let source = collection.source.source
        let lower = source.boundaryIndex(
            atOrBefore: line.contentRange.lowerBound
        )
        let upper = source.boundaryIndex(
            atOrBefore: line.contentRange.upperBound
        )
        let ranges = (lower..<upper).map
        {
            source.graphemeBoundaries[$0]..<source.graphemeBoundaries[$0 + 1]
        }
        var points = [ParagraphBreak(
            position: line.contentRange.lowerBound,
            visibleEnd: line.contentRange.lowerBound, kind: .start
        )]
        for range in ranges
            where range.upperBound < line.contentRange.upperBound
        {
            points.append(.init(position: range.upperBound,
                                visibleEnd: range.upperBound, kind: .emergency))
        }
        var cursor = 0
        var terminalVisible = line.contentRange.upperBound
        while cursor < ranges.count
        {
            let first = ranges[cursor]
            guard ParagraphWhitespace.contains(first, units: source.utf16)
            else
            {
                cursor += 1
                continue
            }
            var end = first.upperBound
            while cursor < ranges.count,
                  ParagraphWhitespace.contains(
                      ranges[cursor], units: source.utf16
                  )
            {
                end = ranges[cursor].upperBound
                cursor += 1
            }
            if end == line.contentRange.upperBound
            {
                terminalVisible = first.lowerBound
            }
            else
            {
                points.append(.init(
                    position: end, visibleEnd: first.lowerBound, kind: .space
                ))
            }
        }
        try Self.appendHyphens(
            collection, within: line.contentRange, to: &points
        )
        let terminal: ParagraphTerminal
        if let ending = line.ending
        {
            terminal = .hard(ending)
        }
        else
        {
            terminal = .end
        }
        points.append(.init(
            position: line.range.upperBound, visibleEnd: terminalVisible,
            kind: .terminal(terminal)
        ))
        self.line = line
        breaks = points.sorted
        {
            if $0.position != $1.position
            {
                return $0.position < $1.position
            }
            return $0.kind.rank < $1.kind.rank
        }
    }
}
