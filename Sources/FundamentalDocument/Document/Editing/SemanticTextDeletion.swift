struct SemanticTextDeletion: Equatable, Sendable
{
    let range: DocumentRange

    init?(range: DocumentRange)
    {
        guard !range.isCollapsed,
              range.start.blockID == range.end.blockID
        else
        {
            return nil
        }

        self.range = range
    }
}
