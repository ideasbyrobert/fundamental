enum SemanticRunFormatting
{
    static func applying(
        _ assignment: (SemanticRunAttributes) -> SemanticRunAttributes,
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
                  length > 0
            else
            {
                result.append(run)
                continue
            }
            let attributes = assignment(run.attributes)
            guard attributes != run.attributes
            else
            {
                result.append(run)
                continue
            }
            guard let lower = DocumentUTF16Offset(
                max(0, lowerBound.value - start)
            ), let upper = DocumentUTF16Offset(
                min(length, upperBound.value - start)
            ), let partition = SemanticRunPartition(
                runs: [run], lowerBound: lower, upperBound: upper
            )
            else
            {
                return nil
            }
            result += partition.prefix
            result += partition.selected.map
            {
                SemanticRun(text: $0.text, attributes: attributes)
            }
            result += partition.suffix
        }
        return upperBound.value <= position ? result : nil
    }
}
