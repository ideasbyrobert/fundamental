package struct SemanticBlockStyleChange: Equatable, Sendable
{
    let range: DocumentRange
    let operation: SemanticBlockStyleOperation

    package init(range: DocumentRange, style: CanonicalBlockStyle)
    {
        self.range = range
        operation = .assign(style)
    }

    package init(removingListsIn range: DocumentRange)
    {
        self.range = range
        operation = .removeLists
    }
}
