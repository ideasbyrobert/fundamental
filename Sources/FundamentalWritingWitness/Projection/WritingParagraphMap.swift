import Foundation
import FundamentalDocument

struct WritingParagraphMap: Equatable, Sendable
{
    let spans: [WritingParagraphSpan]
    let text: String
    let utf16Count: Int

    init?(blocks: [IdentifiedSemanticBlock])
    {
        guard !blocks.isEmpty,
              blocks.count <= WritingSurfacePolicy.maximumParagraphs
        else
        {
            return nil
        }
        var spans: [WritingParagraphSpan] = []
        var parts: [String] = []
        var count = 0
        for (index, block) in blocks.enumerated()
        {
            guard let text = Self.spelling(block.block, startingAt: count)
            else
            {
                return nil
            }
            let start = count
            let (end, overflow) = count.addingReportingOverflow(
                text.utf16.count
            )
            guard !overflow, end <= WritingSurfacePolicy.maximumUTF16Units
            else
            {
                return nil
            }
            let separator = index == blocks.count - 1 ? "" :
                text.unicodeScalars.last?.value == 0x0D ? "\r\n" : "\n"
            let (next, seamOverflow) = end.addingReportingOverflow(
                separator.utf16.count
            )
            guard !seamOverflow,
                  next <= WritingSurfacePolicy.maximumUTF16Units
            else
            {
                return nil
            }
            spans.append(WritingParagraphSpan(
                blockID: block.blockID,
                range: NSRange(location: start, length: end - start),
                separatorLength: separator.utf16.count
            ))
            parts.append(text)
            parts.append(separator)
            count = next
        }
        self.spans = spans
        text = parts.joined()
        utf16Count = count
    }
}
