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
        var paragraphs: [String] = []
        var count = 0
        for block in blocks
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
            spans.append(WritingParagraphSpan(
                blockID: block.blockID,
                range: NSRange(location: start, length: end - start)
            ))
            paragraphs.append(text)
            count = end + 1
        }
        self.spans = spans
        text = paragraphs.joined(separator: "\n")
        utf16Count = count - 1
    }
}
