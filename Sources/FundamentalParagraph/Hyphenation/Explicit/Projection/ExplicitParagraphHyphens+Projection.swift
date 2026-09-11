extension ExplicitParagraphHyphens
{
    package func project(
        _ range: Range<Int>, end: ExplicitSliceEnd = .unbroken
    ) throws(ExplicitProjectionFailure) -> ExplicitDisplaySlice
    {
        guard source.source.isBoundary(range.lowerBound),
              source.source.isBoundary(range.upperBound)
        else
        {
            throw .invalidRange(range)
        }
        guard source.endings(in: range).ranges.isEmpty
        else
        {
            throw .hardEnding
        }
        let selection = try selectedBreak(end, range: range)
        var atoms: [ExplicitDisplayAtom] = []
        for fragment in source.fragments(in: range).fragments
        {
            let match = ParagraphRangeSearch.intersecting(
                fragment.paragraphRange, count: softMarks.count
            )
            {
                softMarks[$0].range
            }
            var cursor = fragment.paragraphRange.lowerBound
            for index in match.indices
            {
                let mark = softMarks[index]
                append(
                    cursor..<mark.range.lowerBound,
                    fragment, .source, to: &atoms
                )
                let kind: ExplicitDisplayAtom.Kind
                if case let .explicit(value) = selection, value.mark == mark
                {
                    kind = .conditionalHyphen
                }
                else
                {
                    kind = .suppressedSoftHyphen
                }
                append(mark.range, fragment, kind, to: &atoms)
                cursor = mark.range.upperBound
            }
            append(
                cursor..<fragment.paragraphRange.upperBound,
                fragment, .source, to: &atoms
            )
        }
        return ExplicitDisplaySlice(
            source: source, range: range, selection: selection, atoms: atoms
        )
    }

    private func append(
        _ range: Range<Int>, _ owner: WordRunFragment,
        _ kind: ExplicitDisplayAtom.Kind, to atoms: inout [ExplicitDisplayAtom]
    )
    {
        guard !range.isEmpty
        else
        {
            return
        }
        let lower = owner.runRange.lowerBound
            + range.lowerBound - owner.paragraphRange.lowerBound
        atoms.append(.init(fragment: .init(
            runIndex: owner.runIndex, paragraphRange: range,
            runRange: lower..<(lower + range.count)
        ), kind: kind))
    }
}
