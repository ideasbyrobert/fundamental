package enum EditableSemanticBlock: Equatable, Sendable
{
    case paragraph(SemanticParagraph)
    case heading(SemanticHeading)
    case listItem(SemanticListItem)
    case code(SemanticCodeBlock)

    package init?(_ block: SemanticBlock)
    {
        switch block
        {
        case let .paragraph(paragraph):
            self = .paragraph(paragraph)
        case let .heading(heading):
            self = .heading(heading)
        case let .listItem(item):
            self = .listItem(item)
        case let .code(code):
            self = .code(code)
        case .table:
            return nil
        }
    }

    package var runs: [SemanticRun]
    {
        switch self
        {
        case let .paragraph(paragraph):
            paragraph.runs
        case let .heading(heading):
            heading.runs
        case let .listItem(item):
            item.runs
        case let .code(code):
            code.runs
        }
    }

    var semanticBlock: SemanticBlock
    {
        switch self
        {
        case let .paragraph(paragraph):
            .paragraph(paragraph)
        case let .heading(heading):
            .heading(heading)
        case let .listItem(item):
            .listItem(item)
        case let .code(code):
            .code(code)
        }
    }
}
