extension SemanticTextBatchBlock
{
    static func admits(
        _ ordered: [SemanticTextSubstitution],
        in block: EditableSemanticBlock, text: String
    ) -> Bool
    {
        var precedingEnd = 0
        var boundaries = Set<Int>()
        for change in ordered
        {
            guard change.lowerBound >= precedingEnd,
                  AppliedSemanticTextEdit.admits(change.text, in: block)
            else
            {
                return false
            }
            precedingEnd = change.upperBound
            boundaries.insert(change.lowerBound)
            boundaries.insert(change.upperBound)
        }
        var offset = 0
        boundaries.remove(offset)
        for character in text
        {
            offset += character.utf16.count
            boundaries.remove(offset)
        }
        return boundaries.isEmpty
    }
}
