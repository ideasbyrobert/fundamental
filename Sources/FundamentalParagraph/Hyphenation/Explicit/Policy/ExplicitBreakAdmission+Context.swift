extension ExplicitBreakAdmission
{
    static func hasAlphabeticContext(
        _ mark: SourceHyphenationMark, group: MarkedWordGroup,
        source: ParagraphWordSource
    ) -> Bool
    {
        let text = source.source
        let boundaries = text.graphemeBoundaries
        let left = text.boundaryIndex(atOrBefore: mark.range.lowerBound)
        let right = text.boundaryIndex(atOrBefore: mark.range.upperBound)
        guard left > 0, right < boundaries.count - 1,
              right == left + 1,
              boundaries[left - 1] >= group.range.lowerBound,
              boundaries[right + 1] <= group.range.upperBound
        else
        {
            return false
        }
        let ranges = [
            boundaries[left - 1]..<boundaries[left],
            boundaries[right]..<boundaries[right + 1]
        ]
        return ranges.allSatisfy
        {
            SpellingCharacter.alphabetic(
                String(decoding: text.utf16[$0], as: UTF16.self)
            )
        }
    }
}
