extension CanonicalBlockStyle
{
    var semanticKind: SemanticBlockKind
    {
        switch self
        {
        case .title, .heading, .subheading:
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
        case .title:
            1
        case .heading:
            2
        case .subheading:
            3
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
        case .heading:
            .heading2
        case .subheading:
            .heading3
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
