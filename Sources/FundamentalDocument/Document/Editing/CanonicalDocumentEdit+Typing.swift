extension CanonicalDocumentEdit
{
    var typingRange: DocumentRange?
    {
        switch self
        {
        case let .text(.insertion(value)):
            .caret(at: value.point)
        case let .text(.replacement(value)):
            value.range
        case let .text(.deletion(value)):
            value.range
        case let .paragraphs(value):
            value.range
        case let .split(value):
            .caret(at: value.point)
        case .merge:
            nil
        }
    }

    var insertedTypingAttributes: SemanticRunAttributes?
    {
        switch self
        {
        case let .text(.insertion(value)):
            return value.insertion.attributes
        case let .text(.replacement(value)):
            return value.insertion.attributes
        case let .paragraphs(value):
            for paragraph in value.paragraphs.reversed()
            {
                if let run = paragraph.runs.last(where: { !$0.text.isEmpty })
                {
                    return run.attributes
                }
            }
            return nil
        case .text(.deletion), .split, .merge:
            return nil
        }
    }
}
