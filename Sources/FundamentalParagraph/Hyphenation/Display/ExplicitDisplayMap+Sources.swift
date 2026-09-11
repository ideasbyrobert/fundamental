extension ExplicitDisplayMap
{
    package func sources(in query: Range<Int>) throws -> [ExplicitDisplayAtom]
    {
        guard !query.isEmpty, query.lowerBound >= 0,
              query.upperBound <= units.count
        else
        {
            throw ExplicitShapingFailure.displayRange(query)
        }
        let match = ParagraphRangeSearch.intersecting(
            query, count: occupied.count
        )
        {
            occupied[$0].range
        }
        return match.indices.map
        {
            index in
            let interval = occupied[index]
            let atom = interval.atom
            if atom.kind == .conditionalHyphen
            {
                return atom
            }
            let lower = max(query.lowerBound, interval.range.lowerBound)
                - interval.range.lowerBound
            let upper = min(query.upperBound, interval.range.upperBound)
                - interval.range.lowerBound
            let owner = atom.fragment
            let source = owner.paragraphRange.lowerBound
            let local = owner.runRange.lowerBound
            return ExplicitDisplayAtom(fragment: WordRunFragment(
                runIndex: owner.runIndex,
                paragraphRange: (source + lower)..<(source + upper),
                runRange: (local + lower)..<(local + upper)
            ), kind: .source)
        }
    }
}
