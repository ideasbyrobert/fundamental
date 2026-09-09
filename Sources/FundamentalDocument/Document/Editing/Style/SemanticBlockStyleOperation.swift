enum SemanticBlockStyleOperation: Equatable, Sendable
{
    case assign(CanonicalBlockStyle)
    case removeLists

    func applying(to block: SemanticBlock) -> SemanticBlock?
    {
        guard let editable = EditableSemanticBlock(block)
        else
        {
            return nil
        }
        switch self
        {
        case let .assign(style):
            guard editable.isProse, style != .monostyled
            else
            {
                return nil
            }
            return style.semanticBlock(runs: editable.runs)
        case .removeLists:
            guard case .listItem = block
            else
            {
                return block
            }
            return .paragraph(SemanticParagraph(runs: editable.runs))
        }
    }
}
