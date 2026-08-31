enum SemanticTable: Equatable, Sendable
{
    case regular(RegularSemanticTable)
    case captioned(CaptionedSemanticTable)

    var content: SemanticTableContent
    {
        switch self
        {
        case let .regular(table):
            table.content
        case let .captioned(table):
            table.content
        }
    }
}
