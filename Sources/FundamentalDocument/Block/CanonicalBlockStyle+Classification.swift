extension CanonicalBlockStyle
{
    var semanticKind: SemanticBlockKind
    {
        switch self
        {
        case .title, .heading1, .heading, .subheading,
             .heading4, .heading5, .heading6:
            .heading
        case .body:
            .paragraph
        case .monostyled:
            .code
        case .bulleted, .numbered:
            .listItem
        }
    }

    var headingLevel: Int?
    {
        switch self
        {
        case .title, .heading1:
            1
        case .heading:
            2
        case .subheading:
            3
        case .heading4:
            4
        case .heading5:
            5
        case .heading6:
            6
        case .body, .monostyled, .bulleted, .numbered:
            nil
        }
    }

    var roleHint: SemanticRoleHint
    {
        switch self
        {
        case .title:
            .title
        case .heading1:
            .heading1
        case .heading:
            .heading2
        case .subheading:
            .heading3
        case .heading4:
            .heading4
        case .heading5:
            .heading5
        case .heading6:
            .heading6
        case .body:
            .body
        case .monostyled:
            .code
        case .bulleted:
            .bullet
        case .numbered:
            .numberedItem
        }
    }
}
