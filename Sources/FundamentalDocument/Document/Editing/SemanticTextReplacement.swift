package struct SemanticTextReplacement: Equatable, Sendable
{
    let range: DocumentRange
    let insertion: SemanticInsertion

    package init?(
        range: DocumentRange,
        insertion: SemanticInsertion
    )
    {
        guard !range.isCollapsed,
              range.start.blockID == range.end.blockID
        else
        {
            return nil
        }

        self.range = range
        self.insertion = insertion
    }
}
