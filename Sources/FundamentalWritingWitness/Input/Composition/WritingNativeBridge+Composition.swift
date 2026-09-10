import AppKit
import FundamentalDocument

extension WritingNativeBridge
{
    @discardableResult
    func finishComposition(in view: NSTextView) -> Bool
    {
        guard let current = composition
        else
        {
            return true
        }
        guard matches(current, in: view)
        else
        {
            project(in: view)
            return false
        }
        return accept(current, in: view)
    }

    func commitComposition(
        _ value: Any, replacing range: NSRange, in view: NSTextView
    )
    {
        guard let current = composition, matches(current, in: view),
              let inserted = WritingCompositionRange.string(value),
              let next = current.replacing(
                  range.location == NSNotFound ? current.markedRange : range,
                  with: inserted,
                  selecting: NSRange(location: inserted.utf16.count, length: 0)
              )
        else
        {
            project(in: view)
            return
        }
        accept(next, in: view)
    }

    @discardableResult
    func accept(_ candidate: WritingComposition, in view: NSTextView) -> Bool
    {
        defer
        {
            project(in: view)
        }
        guard let input = candidate.input
        else
        {
            return false
        }
        switch session.submit(input.command)
        {
        case .applied, .unchanged:
            return true
        case .refused:
            return false
        }
    }
}
