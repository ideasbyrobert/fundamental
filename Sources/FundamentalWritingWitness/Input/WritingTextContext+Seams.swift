import Foundation

extension WritingTextContext
{
    func seamAdjustment(
        replacing native: NSRange, with replacement: String,
        in projection: WritingProjection
    ) -> Int
    {
        guard let span = projection.map.spans.first(where:
                { $0.blockID == range.start.blockID }),
              span.separatorLength > 0,
              NSMaxRange(native) == NSMaxRange(span.range)
        else
        {
            return 0
        }
        let preceding: UInt16? = native.location > span.range.location
            ? (projection.text as NSString).character(at: native.location - 1)
            : nil
        let last = replacement.utf16.last ?? preceding
        let length = last == 0x0D ? 2 : 1
        return length - span.separatorLength
    }
}
