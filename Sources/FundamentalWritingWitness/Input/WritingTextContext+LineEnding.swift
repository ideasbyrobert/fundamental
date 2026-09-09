import Foundation

extension WritingTextContext
{
    func lineEnding(in projection: WritingProjection) -> String?
    {
        guard isCode, let span = projection.map.spans.first(where:
            { $0.blockID == range.start.blockID })
        else
        {
            return nil
        }
        let source = (projection.text as NSString).substring(with: span.range)
        return WritingSourceLineEnding.at(range.start.utf16Offset.value,
                                           in: source as NSString)
    }
}
