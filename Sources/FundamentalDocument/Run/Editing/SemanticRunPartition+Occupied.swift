extension SemanticRunPartition
{
    static func appendOccupied(
        _ run: SemanticRun,
        from runLowerBound: Int,
        to runUpperBound: Int,
        lowerBound: Int,
        upperBound: Int,
        prefix: inout [SemanticRun],
        selected: inout [SemanticRun],
        suffix: inout [SemanticRun]
    ) -> Bool
    {
        let prefixUpperBound = min(runUpperBound, lowerBound)
        if runLowerBound < prefixUpperBound
        {
            guard let fragment = fragment(
                run,
                runLowerBound: runLowerBound,
                lowerBound: runLowerBound,
                upperBound: prefixUpperBound
            )
            else
            {
                return false
            }
            prefix.append(fragment)
        }

        let selectedLowerBound = max(runLowerBound, lowerBound)
        let selectedUpperBound = min(runUpperBound, upperBound)
        if selectedLowerBound < selectedUpperBound
        {
            guard let fragment = fragment(
                run,
                runLowerBound: runLowerBound,
                lowerBound: selectedLowerBound,
                upperBound: selectedUpperBound
            )
            else
            {
                return false
            }
            selected.append(fragment)
        }

        let suffixLowerBound = max(runLowerBound, upperBound)
        if suffixLowerBound < runUpperBound
        {
            guard let fragment = fragment(
                run,
                runLowerBound: runLowerBound,
                lowerBound: suffixLowerBound,
                upperBound: runUpperBound
            )
            else
            {
                return false
            }
            suffix.append(fragment)
        }
        return true
    }
}
