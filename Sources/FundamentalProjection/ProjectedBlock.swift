package enum ProjectedBlock: Equatable, Sendable
{
    case prose(
        source: ProjectedBlockSource,
        prose: ProjectedProse
    )
    case code(
        source: ProjectedBlockSource,
        code: ProjectedCode
    )
    case table(
        source: ProjectedBlockSource,
        table: ProjectedTableRecord
    )

    package var source: ProjectedBlockSource
    {
        switch self
        {
        case let .prose(source, _):
            source
        case let .code(source, _):
            source
        case let .table(source, _):
            source
        }
    }
}
