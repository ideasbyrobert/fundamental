import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ kind: SemanticTableRepairKind
    ) -> ProjectedTableRepairKind
    {
        switch kind
        {
        case .nonpositiveRowSpanNormalizedToOne:
            .nonpositiveRowSpanNormalizedToOne
        case .nonpositiveColumnSpanNormalizedToOne:
            .nonpositiveColumnSpanNormalizedToOne
        case .headerRowCountClamped:
            .headerRowCountClamped
        case .contradictoryCellHeaderFlagDiscarded:
            .contradictoryCellHeaderFlagDiscarded
        case .blankSourceLocationDiscarded:
            .blankSourceLocationDiscarded
        }
    }
}
