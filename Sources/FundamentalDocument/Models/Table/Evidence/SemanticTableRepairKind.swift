enum SemanticTableRepairKind:
    String,
    CaseIterable,
    Equatable,
    Sendable
{
    case nonpositiveRowSpanNormalizedToOne
    case nonpositiveColumnSpanNormalizedToOne
    case headerRowCountClamped
    case contradictoryCellHeaderFlagDiscarded
    case blankSourceLocationDiscarded
}
