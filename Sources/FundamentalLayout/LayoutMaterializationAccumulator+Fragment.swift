extension LayoutMaterializationAccumulator
{
    mutating func consume(
        _ fragment: LayoutFragment
    ) -> Bool
    {
        switch fragment
        {
        case let .lines(value):
            return consume(value.line)
        case let .grid(value):
            switch value.content
            {
            case let .captionLine(line):
                return consume(line)
            case let .cellLine(line):
                return consume(line.line)
            case .region, .columnTrack, .rowTrack, .cell, .rule:
                return true
            }
        }
    }

    mutating func consume(
        _ line: LayoutLine
    ) -> Bool
    {
        let caretCount = line.remainingCaretStops.count
            .addingReportingOverflow(1)
        guard !caretCount.overflow,
              consumeText(line.text),
              consumeCaretStops(caretCount.partialValue),
              consume(line.sourceSlices),
              consume(line.defaultFont)
        else
        {
            return false
        }
        for run in line.glyphRuns
        {
            guard consume(run)
            else
            {
                return false
            }
        }
        if let marker = line.marker
        {
            guard consumeText(marker.source.label)
            else
            {
                return false
            }
            for run in marker.glyphRuns
            {
                guard consume(run)
                else
                {
                    return false
                }
            }
        }
        return true
    }

    mutating func consumeStructuralFont(
        of block: NativeBlockLayout
    ) -> Bool
    {
        for grid in block.grids
        {
            guard consume(grid.structuralFont)
            else
            {
                return false
            }
        }
        return true
    }
}
