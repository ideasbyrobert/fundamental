struct SemanticTextBatchBlock
{
    let runs: [SemanticRun]
    let firstChangedEnd: Int?

    init?(_ values: [SemanticTextSubstitution], in block: EditableSemanticBlock)
    {
        let ordered = values.sorted { $0.lowerBound < $1.lowerBound }
        let text = block.runs.map(\.text).joined()
        guard Self.admits(ordered, in: block, text: text)
        else
        {
            return nil
        }
        let original = Array(text.utf16)
        let changes = ordered.filter
        {
            !original[$0.lowerBound ..< $0.upperBound]
                .elementsEqual($0.text.utf16)
        }
        guard let first = changes.first
        else
        {
            runs = block.runs
            firstChangedEnd = nil
            return
        }
        let (caret, overflow) = first.lowerBound.addingReportingOverflow(
            first.text.utf16.count
        )
        guard !overflow, var cursor = SemanticRunCursor(block.runs)
        else
        {
            return nil
        }
        var result: [SemanticRun] = []
        for change in changes
        {
            guard let prefix = cursor.take(through: change.lowerBound,
                                            keeping: true),
                  cursor.take(through: change.upperBound,
                              keeping: false) != nil
            else
            {
                return nil
            }
            result += prefix
            if !change.text.isEmpty
            {
                result.append(SemanticRun(text: change.text,
                                           attributes: change.attributes))
            }
        }
        guard let suffix = cursor.take(through: cursor.length,
                                        keeping: true, terminal: true)
        else
        {
            return nil
        }
        runs = result + suffix
        firstChangedEnd = caret
    }
}
