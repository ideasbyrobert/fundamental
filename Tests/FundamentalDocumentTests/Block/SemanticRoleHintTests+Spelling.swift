@testable import FundamentalDocument

extension SemanticRoleHintTests
{
    func expectedRawValue(for roleHint: SemanticRoleHint) -> String
    {
        switch roleHint
        {
        case .title:
            "title"
        case .heading1:
            "heading1"
        case .heading2:
            "heading2"
        case .heading3:
            "heading3"
        case .heading4:
            "heading4"
        case .heading5:
            "heading5"
        case .heading6:
            "heading6"
        case .body:
            "body"
        case .quote:
            "quote"
        case .code:
            "code"
        case .bullet:
            "bullet"
        case .numberedItem:
            "numberedItem"
        case .sceneBreak:
            "sceneBreak"
        case .caption:
            "caption"
        }
    }
}
