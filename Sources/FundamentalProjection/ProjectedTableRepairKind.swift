package enum ProjectedTableRepairKind: Int, CaseIterable, Sendable
{
    case nonpositiveRowSpanNormalizedToOne
    case nonpositiveColumnSpanNormalizedToOne
    case headerRowCountClamped
    case contradictoryCellHeaderFlagDiscarded
    case blankSourceLocationDiscarded
}
