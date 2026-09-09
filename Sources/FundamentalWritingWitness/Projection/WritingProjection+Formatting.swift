import FundamentalDocument

extension WritingProjection
{
    var canFormatParagraphs: Bool
    {
        guard let selected = SemanticBlockSelection(
            range: snapshot.selection.range,
            in: snapshot.snapshot.document
        )
        else
        {
            return false
        }
        return selected.blocks.allSatisfy
        {
            switch $0.block
            {
            case .paragraph, .heading, .listItem:
                true
            case .code, .table:
                false
            }
        }
    }
}
