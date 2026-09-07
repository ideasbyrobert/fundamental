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
        if !candidate.text.utf16.elementsEqual(candidate.baseline.text.utf16)
        {
            guard let proposal = candidate.proposal,
                  case .applied = session.submit(proposal.command)
            else
            {
                return false
            }
        }
        if let next = WritingProjection(session.state),
           let selection = WritingSelectionProposal(
               ranges: [candidate.selection], in: next
           )
        {
            session.submit(selection.command)
        }
        return true
    }
}
