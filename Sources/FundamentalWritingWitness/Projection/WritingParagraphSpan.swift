import Foundation
import FundamentalDocument

struct WritingParagraphSpan: Equatable, Sendable
{
    let blockID: FundamentalBlockID
    let range: NSRange
}
