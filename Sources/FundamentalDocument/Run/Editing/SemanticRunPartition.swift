package struct SemanticRunPartition: Equatable, Sendable
{
    package let prefix: [SemanticRun]
    package let selected: [SemanticRun]
    package let suffix: [SemanticRun]

    package init?(
        runs: [SemanticRun],
        lowerBound: DocumentUTF16Offset,
        upperBound: DocumentUTF16Offset
    )
    {
        guard lowerBound <= upperBound,
              Self.admitsScalarBoundary(lowerBound, in: runs),
              Self.admitsScalarBoundary(upperBound, in: runs)
        else
        {
            return nil
        }

        var prefix: [SemanticRun] = []
        var selected: [SemanticRun] = []
        var suffix: [SemanticRun] = []
        var position = 0

        for run in runs
        {
            let length = run.text.utf16.count
            let addition = position.addingReportingOverflow(length)
            guard !addition.overflow
            else
            {
                return nil
            }
            let nextPosition = addition.partialValue

            guard length > 0
            else
            {
                Self.appendEmpty(
                    run,
                    at: position,
                    lowerBound: lowerBound.value,
                    upperBound: upperBound.value,
                    prefix: &prefix,
                    selected: &selected,
                    suffix: &suffix
                )
                continue
            }

            guard Self.appendOccupied(
                run,
                from: position,
                to: nextPosition,
                lowerBound: lowerBound.value,
                upperBound: upperBound.value,
                prefix: &prefix,
                selected: &selected,
                suffix: &suffix
            )
            else
            {
                return nil
            }
            position = nextPosition
        }

        self.prefix = prefix
        self.selected = selected
        self.suffix = suffix
    }
}
