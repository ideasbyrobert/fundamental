import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ alignment: SemanticTableColumnAlignment
    ) -> ProjectedTableColumnAlignment
    {
        switch alignment
        {
        case .leading:
            .leading
        case .center:
            .center
        case .trailing:
            .trailing
        case .unspecified:
            .unspecified
        }
    }

}
