extension SemanticInlineTraitChange
{
    func applying(
        to runs: [SemanticRun], lowerBound: DocumentUTF16Offset,
        upperBound: DocumentUTF16Offset
    ) -> [SemanticRun]?
    {
        guard lowerBound <= upperBound
        else
        {
            return nil
        }
        var result: [SemanticRun] = []
        var position = 0
        for run in runs
        {
            let start = position
            let length = run.text.utf16.count
            let addition = position.addingReportingOverflow(length)
            guard !addition.overflow
            else
            {
                return nil
            }
            position = addition.partialValue
            guard lowerBound.value < position, upperBound.value > start,
                  applying(to: run) != run
            else
            {
                result.append(run)
                continue
            }
            guard let lower = DocumentUTF16Offset(
                max(0, lowerBound.value - start)
            ),
                  let upper = DocumentUTF16Offset(
                      min(length, upperBound.value - start)
                  ),
                  let partition = SemanticRunPartition(
                      runs: [run], lowerBound: lower, upperBound: upper
                  )
            else
            {
                return nil
            }
            result += partition.prefix
            result += partition.selected.map { applying(to: $0) }
            result += partition.suffix
        }
        return upperBound.value <= position ? result : nil
    }
}
