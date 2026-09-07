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
            self = section.level.rawValue <= 2 ? .heading : .subheading
        case .code:
            self = .monostyled
        case let .listItem(item):
            self = item.kind == .bulleted ? .bulleted : .numbered
        case .table:
            return nil
        }
    }
}
