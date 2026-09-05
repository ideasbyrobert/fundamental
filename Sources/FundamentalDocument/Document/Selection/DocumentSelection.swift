package struct DocumentSelection: Equatable, Sendable
{
    package let range: DocumentRange

    package init(range: DocumentRange)
    {
        self.range = range
    }

    static func caret(at point: DocumentPoint) -> DocumentSelection
    {
        DocumentSelection(
            range: DocumentRange.caret(at: point)
        )
    }

    var isCollapsed: Bool
    {
        range.isCollapsed
    }
}
