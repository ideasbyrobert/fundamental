import AppKit
import FundamentalDocument

extension WritingNativeBridge
{
    func mark(
        _ value: Any, selected: NSRange, replacing range: NSRange,
        in view: NSTextView, perform: () -> Void
    )
    {
        guard !projecting, view.textLayoutManager != nil,
              let inserted = WritingCompositionRange.string(value)
        else
        {
            return
        }
        let actual = range.location == NSNotFound
            ? composition?.markedRange ?? view.selectedRange() : range
        let prior = composition ?? WritingComposition.starting(
            at: actual, in: projection
        )
        guard let prior, matches(prior, in: view),
              let next = prior.replacing(actual, with: inserted,
                                         selecting: selected),
              let presentation = WritingTextPresentation(next.presentation,
                                                          zoom: zoom)
        else
        {
            project(in: view)
            return
        }
        composition = next
        composing = true
        view.typingAttributes = presentation.typingAttributes
        perform()
        presentation.restyle(in: view)
        view.typingAttributes = presentation.typingAttributes
        composing = false
        guard matches(next, in: view),
              view.selectedRange() == next.selection,
              inserted.isEmpty || (view.hasMarkedText() &&
                  view.markedRange() == next.markedRange)
        else
        {
            project(in: view)
            return
        }
        if !view.hasMarkedText()
        {
            finishComposition(in: view)
        }
    }

    func matches(_ candidate: WritingComposition, in view: NSTextView) -> Bool
    {
        guard case let .editable(current) = session.state
        else
        {
            return false
        }
        return view.textLayoutManager != nil &&
            candidate.baseline.observation == DocumentObservation(
                snapshot: current.snapshot
            ) &&
            view.string.utf16.elementsEqual(candidate.text.utf16)
    }
}
