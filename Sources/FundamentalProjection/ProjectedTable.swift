package enum ProjectedTable: Equatable, Sendable
{
    case regular(ProjectedTableContent)
    case captioned(
        content: ProjectedTableContent,
        caption: ProjectedTableCaption
    )

    package var content: ProjectedTableContent
    {
        switch self
        {
        case let .regular(content):
            content
        case let .captioned(content, _):
            content
        }
    }
}
