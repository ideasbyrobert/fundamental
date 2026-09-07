package enum ProjectedProseRole: Equatable, Sendable
{
    case body
    case bulleted
    case numbered
    case title
    case section(ProjectedHeadingLevel)
}
