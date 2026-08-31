enum SemanticTableRecord: Equatable, Sendable
{
    case semantic(SemanticTable)
    case sourced(SourcedSemanticTable)

    var table: SemanticTable
    {
        switch self
        {
        case let .semantic(table):
            table
        case let .sourced(table):
            table.table
        }
    }
}
