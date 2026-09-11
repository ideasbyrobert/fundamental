extension WrappingPlan
{
    static func accepts(
        source: WrappingSource, width: Double, lines: [WrappingLineChoice]
    ) -> Bool
    {
        guard !lines.isEmpty
        else
        {
            return false
        }
        var position = 0
        var sourceIndex = 0
        for (index, line) in lines.enumerated()
        {
            guard sourceIndex < source.lines.count,
                  line.range.lowerBound == position,
                  source.isBoundary(line.range.lowerBound),
                  source.isBoundary(line.range.upperBound),
                  line.indentation.isFinite, line.indentation >= 0,
                  line.indentation < width,
                  line.advance.isFinite, line.advance >= 0,
                  line.advance <= width - line.indentation
            else
            {
                return false
            }
            let sourceLine = source.lines[sourceIndex]
            guard line.range.upperBound <= sourceLine.range.upperBound
            else
            {
                return false
            }
            switch line.breakKind
            {
            case .soft, .emergency:
                guard line.range.upperBound > position,
                      line.range.upperBound < sourceLine.contentRange.upperBound
                else
                {
                    return false
                }
            case let .hard(ending):
                guard ending == sourceLine.ending,
                      line.range.upperBound == sourceLine.range.upperBound
                else
                {
                    return false
                }
                sourceIndex += 1
            case .end:
                guard sourceLine.ending == nil,
                      line.range.upperBound == source.utf16.count,
                      index == lines.count - 1
                else
                {
                    return false
                }
                sourceIndex += 1
            }
            position = line.range.upperBound
        }
        return sourceIndex == source.lines.count
            && position == source.utf16.count
    }
}
