extension CodeConversionLines
{
    static func partition(
        _ runs: [SemanticRun], ranges: [Range<Int>]
    ) -> [[SemanticRun]]?
    {
        guard !ranges.isEmpty
        else
        {
            return nil
        }
        var result = Array(repeating: [SemanticRun](), count: ranges.count)
        var line = 0
        var position = 0
        for run in runs
        {
            let units = Array(run.text.utf16)
            let (end, overflow) = position.addingReportingOverflow(units.count)
            guard !overflow
            else
            {
                return nil
            }
            while line + 1 < ranges.count, position >= ranges[line].upperBound
            {
                line += 1
            }
            if units.isEmpty
            {
                result[line].append(run)
            }
            var cursor = position
            while cursor < end
            {
                while line + 1 < ranges.count,
                      cursor >= ranges[line].upperBound
                {
                    line += 1
                }
                let lower = max(cursor, ranges[line].lowerBound)
                let upper = min(end, ranges[line].upperBound)
                if lower < upper
                {
                    let fragment = lower == position && upper == end ? run :
                        SemanticRun(
                            text: String(
                                decoding: units[
                                    (lower - position) ..< (upper - position)
                                ], as: UTF16.self
                            ),
                            attributes: run.attributes
                        )
                    result[line].append(fragment)
                }
                let next = min(end, max(upper, ranges[line].lowerBound))
                guard next > cursor
                else
                {
                    return nil
                }
                cursor = next
            }
            position = end
        }
        guard position == ranges.last?.upperBound
        else
        {
            return nil
        }
        return result
    }
}
