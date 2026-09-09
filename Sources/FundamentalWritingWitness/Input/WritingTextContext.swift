import Foundation
import FundamentalDocument

struct WritingTextContext
{
    let range: DocumentRange
    let separators: Int
    let isCode: Bool

    init?(_ native: NSRange, in projection: WritingProjection)
    {
        guard let range = projection.range(native),
              let first = projection.map.spans.firstIndex(where:
                { $0.blockID == range.start.blockID }),
              let last = projection.map.spans.firstIndex(where:
                { $0.blockID == range.end.blockID }), first <= last
        else
        {
            return nil
        }
        let blocks = projection.snapshot.snapshot.document.content.blocks
        let code = blocks[first ... last].contains
        {
            if case .code = $0.block
            {
                return true
            }
            return false
        }
        guard !code || first == last
        else
        {
            return nil
        }
        self.range = range
        separators = last - first
        isCode = code
    }

    func replacement(_ source: String) -> String
    {
        isCode ? source : source
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
    }
}
