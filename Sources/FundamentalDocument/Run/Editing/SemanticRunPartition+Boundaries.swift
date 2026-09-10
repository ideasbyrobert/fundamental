extension SemanticRunPartition
{
    static func admitsScalarBoundary(
        _ offset: DocumentUTF16Offset,
        in runs: [SemanticRun]
    ) -> Bool
    {
        let text = runs.map(\.text).joined()
        guard offset.value <= text.utf16.count
        else
        {
            return false
        }

        let utf16Index = text.utf16.index(
            text.utf16.startIndex,
            offsetBy: offset.value
        )
        return utf16Index.samePosition(in: text.unicodeScalars) != nil
    }

    static func appendEmpty(
        _ run: SemanticRun,
        at position: Int,
        lowerBound: Int,
        upperBound: Int,
        prefix: inout [SemanticRun],
        selected: inout [SemanticRun],
        suffix: inout [SemanticRun]
    )
    {
        if position < lowerBound
        {
            prefix.append(run)
        }
        else if position < upperBound
        {
            selected.append(run)
        }
        else
        {
            suffix.append(run)
        }
    }
}
