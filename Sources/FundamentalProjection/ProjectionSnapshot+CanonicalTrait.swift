import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ trait: SemanticInlineTrait
    ) -> ProjectedInlineTrait
    {
        switch trait
        {
        case .strong:
            .strong
        case .emphasis:
            .emphasis
        case .underline:
            .underline
        case .strikethrough:
            .strikethrough
        case .inlineCode:
            .inlineCode
        case .superscript:
            .superscript
        case .subscriptText:
            .subscriptText
        }
    }

}
