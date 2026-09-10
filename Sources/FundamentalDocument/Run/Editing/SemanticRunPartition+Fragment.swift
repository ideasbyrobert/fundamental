extension SemanticRunPartition
{
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
