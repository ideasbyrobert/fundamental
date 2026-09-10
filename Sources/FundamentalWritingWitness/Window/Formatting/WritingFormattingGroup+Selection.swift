import FundamentalDocument

extension WritingFormattingGroup
{
    func selectionTitles(in projection: WritingProjection) -> [String]
    {
        guard let selection = SemanticBlockSelection(
            range: projection.snapshot.selection.range,
            in: projection.snapshot.snapshot.document
        )
        else
        {
            return []
        }
        return selection.blocks.map { selectionTitle(for: $0.block) }
    }

    private func selectionTitle(for block: SemanticBlock) -> String
    {
        if self == .list
        {
            if case let .listItem(item) = block
            {
                return item.kind == .numbered ? "Numbered" : "Bulleted"
            }
            return "No List"
        }
        switch block
        {
        case .paragraph, .listItem:
            return "Body"
        case .heading(.title):
            return "Title"
        case let .heading(.section(section)):
            return "Heading \(section.level.rawValue)"
        case .code:
            return "Code"
        case .table:
            return "Table"
        }
    }
}
