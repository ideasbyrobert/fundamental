import Foundation

extension WritingProjection
{
    func nativeSelection(_ proposed: NSRange, from previous: NSRange)
        -> NSRange?
    {
        let (end, overflow) = proposed.location.addingReportingOverflow(
            proposed.length
        )
        guard proposed.location >= 0, proposed.length >= 0, !overflow,
              end <= map.utf16Count
        else
        {
            return nil
        }
        let source = text as NSString
        func boundary(_ offset: Int, from prior: Int) -> Int
        {
            guard offset > 0, offset < source.length,
                  source.character(at: offset - 1) == 0x0D,
                  source.character(at: offset) == 0x0A
            else
            {
                return offset
            }
            return offset < prior ? offset - 1 : offset + 1
        }
        if proposed.length == 0
        {
            let prior = proposed.location < previous.location
                ? previous.location : NSMaxRange(previous)
            return NSRange(location: boundary(proposed.location, from: prior),
                           length: 0)
        }
        let lower = boundary(proposed.location, from: previous.location)
        let upper = boundary(end, from: NSMaxRange(previous))
        guard lower <= upper
        else
        {
            return nil
        }
        return NSRange(location: lower, length: upper - lower)
    }
}
