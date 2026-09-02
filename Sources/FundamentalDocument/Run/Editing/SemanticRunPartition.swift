struct SemanticRunPartition: Equatable, Sendable
{
    let prefix: [SemanticRun]
    let selected: [SemanticRun]
    let suffix: [SemanticRun]

    init?(
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

private extension SemanticRunPartition
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

    static func fragment(
        _ run: SemanticRun,
        runLowerBound: Int,
        lowerBound: Int,
        upperBound: Int
    ) -> SemanticRun?
    {
        let localLowerBound = lowerBound - runLowerBound
        let localUpperBound = upperBound - runLowerBound
        guard localLowerBound < localUpperBound
        else
        {
            return nil
        }
        guard localLowerBound > 0 || localUpperBound < run.text.utf16.count
        else
        {
            return run
        }

        let utf16 = run.text.utf16
        let lowerUTF16Index = utf16.index(
            utf16.startIndex,
            offsetBy: localLowerBound
        )
        let upperUTF16Index = utf16.index(
            utf16.startIndex,
            offsetBy: localUpperBound
        )
        guard let lowerIndex = lowerUTF16Index.samePosition(
            in: run.text.unicodeScalars
        ),
        let upperIndex = upperUTF16Index.samePosition(
            in: run.text.unicodeScalars
        )
        else
        {
            return nil
        }

        let spelling = String(
            run.text.unicodeScalars[lowerIndex ..< upperIndex]
        )
        guard !spelling.isEmpty
        else
        {
            return nil
        }
        return SemanticRun(
            text: spelling,
            attributes: run.attributes
        )
    }
}
