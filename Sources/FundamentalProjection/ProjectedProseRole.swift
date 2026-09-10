package enum ProjectedProseRole: Equatable, Sendable
{
    case body
    case bulleted(ProjectedListPosition)
    case numbered(ProjectedListPosition)
    case title
    case section(ProjectedHeadingLevel)
}
