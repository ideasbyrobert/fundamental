struct SemanticRunCursor
{
    let runs: [SemanticRun]
    let bounds: [Range<Int>]
    let length: Int
    var index = 0
    var position = 0

    init?(_ runs: [SemanticRun])
    {
        var bounds: [Range<Int>] = []
        var end = 0
        for run in runs
        {
            let (next, overflow) = end.addingReportingOverflow(
                run.text.utf16.count
            )
            guard !overflow
            else
            {
                return nil
            }
            bounds.append(end ..< next)
            end = next
        }
        self.runs = runs
        self.bounds = bounds
        length = end
    }

    mutating func take(
        through end: Int, keeping: Bool, terminal: Bool = false
    ) -> [SemanticRun]?
    {
        guard end >= position, end <= length
        else
        {
            return nil
        }
        var result: [SemanticRun] = []
        while index < runs.count
        {
            let bound = bounds[index]
            if bound.isEmpty
            {
                guard position < end || (terminal && position == end)
                else
                {
                    break
                }
                if keeping
                {
                    result.append(runs[index])
                }
                index += 1
                continue
            }
            guard position < end
            else
            {
                break
            }
            let next = min(end, bound.upperBound)
            if keeping
            {
                guard let fragment = SemanticRunPartition.fragment(
                    runs[index], runLowerBound: bound.lowerBound,
                    lowerBound: position, upperBound: next
                )
                else
                {
                    return nil
                }
                result.append(fragment)
            }
            position = next
            if position == bound.upperBound
            {
                index += 1
            }
        }
        return result
    }
}
