package struct SemanticTextSubstitution: Equatable, Sendable
{
    let range: DocumentRange
    let text: String
    let attributes: SemanticRunAttributes

    package init?(
        range: DocumentRange, text: String, attributes: SemanticRunAttributes
    )
    {
        guard !range.isCollapsed,
              range.start.blockID == range.end.blockID
        else
        {
            return nil
        }
        self.range = range
        self.text = text
        self.attributes = attributes
    }

    var lowerBound: Int
    {
        min(range.start.utf16Offset.value, range.end.utf16Offset.value)
    }

    var upperBound: Int
    {
        max(range.start.utf16Offset.value, range.end.utf16Offset.value)
    }
}
