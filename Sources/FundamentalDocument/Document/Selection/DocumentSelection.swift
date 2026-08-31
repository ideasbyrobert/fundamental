struct DocumentSelection: Equatable, Sendable
{
    let range: DocumentRange

    init(range: DocumentRange)
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
