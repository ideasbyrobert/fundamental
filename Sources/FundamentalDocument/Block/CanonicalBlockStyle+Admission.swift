extension CanonicalBlockStyle
{
    package init?(_ block: SemanticBlock)
    {
        switch block
        {
        case .paragraph:
            self = .body
        case .heading(.title):
            self = .title
        case let .heading(.section(section)):
            switch section.level
            {
            case .one:
                self = .heading1
            case .two:
                self = .heading
            case .three:
                self = .subheading
            case .four:
                self = .heading4
            case .five:
                self = .heading5
            case .six:
                self = .heading6
            }
        case .code:
            self = .monostyled
        case let .listItem(item):
            self = item.kind == .bulleted ? .bulleted : .numbered
        case .table:
            return nil
        }
    }
}
