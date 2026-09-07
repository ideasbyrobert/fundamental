import Foundation
import FundamentalDocument

extension WritingParagraphMap
{
    func offset(_ point: DocumentPoint) -> Int?
    {
        guard let span = spans.first(where: { $0.blockID == point.blockID }),
              point.utf16Offset.value <= span.range.length
        else
        {
            return nil
        }
        return span.range.location + point.utf16Offset.value
    }

    func point(_ offset: Int, in document: CanonicalDocument) -> DocumentPoint?
    {
        guard offset >= 0, offset <= utf16Count
        else
        {
            return nil
        }
        var lower = 0
        var upper = spans.count
        while lower < upper
        {
            let middle = lower + (upper - lower) / 2
            if spans[middle].range.location <= offset
            {
                lower = middle + 1
            }
            else
            {
                upper = middle
            }
        }
        guard lower > 0
        else
        {
            return nil
        }
        let span = spans[lower - 1]
        guard let local = DocumentUTF16Offset(offset - span.range.location),
              local.value <= span.range.length
        else
        {
            return nil
        }
        return DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: span.blockID,
            utf16Offset: local
        )
    }
}
