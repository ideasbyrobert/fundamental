import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ level: SemanticHeadingLevel
    ) -> ProjectedHeadingLevel
    {
        switch level
        {
        case .one:
            .one
        case .two:
            .two
        case .three:
            .three
        case .four:
            .four
        case .five:
            .five
        case .six:
            .six
        }
    }

}
