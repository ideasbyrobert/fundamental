package struct SemanticBlockStyleChange: Equatable, Sendable
{
    let range: DocumentRange
    let style: CanonicalBlockStyle

    package init(range: DocumentRange, style: CanonicalBlockStyle)
    {
        self.range = range
        self.style = style
    }
}
