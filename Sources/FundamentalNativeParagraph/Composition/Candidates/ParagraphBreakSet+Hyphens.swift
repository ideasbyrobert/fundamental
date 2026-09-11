extension ParagraphBreakSet
{
    static func appendHyphens(
        _ collection: ParagraphHyphens, within range: Range<Int>,
        to points: inout [ParagraphBreak]
    ) throws
    {
        func interior(_ offset: Int) -> Bool
        {
            offset > range.lowerBound && offset < range.upperBound
        }
        for (index, record) in collection.explicit.records.enumerated()
        {
            if case let .opportunity(value) = record.outcome,
               interior(value.sourceOffset)
            {
                points.append(.init(
                    position: value.sourceOffset,
                    visibleEnd: value.sourceOffset,
                    kind: .authored(
                        try collection.explicit.select(index),
                        conditional: value.ink == .conditionalHyphen
                    )
                ))
            }
        }
        for (index, ink) in collection.inks.enumerated()
        {
            let offset = ink.candidate.sourceOffset
            if interior(offset)
            {
                points.append(.init(
                    position: offset, visibleEnd: offset,
                    kind: .automatic(try collection.selectAutomatic(index))
                ))
            }
        }
    }
}
