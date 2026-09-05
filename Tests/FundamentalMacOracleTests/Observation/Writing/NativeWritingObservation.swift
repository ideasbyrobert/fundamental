import AppKit

enum NativeWritingObservation: Equatable
{
    case proposal(
        ranges: [NSRange],
        replacements: [[UInt16]]?,
        spelling: [UInt16],
        selection: NSRange,
        marked: NSRange
    )
    case changed([UInt16])
    case selected(NSRange)

    var isProposal: Bool
    {
        if case .proposal = self
        {
            return true
        }
        return false
    }

    var isTextChange: Bool
    {
        if case .changed = self
        {
            return true
        }
        return false
    }
}
