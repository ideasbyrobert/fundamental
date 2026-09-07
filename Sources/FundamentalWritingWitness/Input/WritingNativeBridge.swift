import AppKit
import FundamentalDocument

@MainActor
final class WritingNativeBridge: NSObject, NSTextViewDelegate
{
    let session: DocumentSession
    var projection: WritingProjection
    var projecting = false
    var composing = false
    var composition: WritingComposition?
    var didChange: (@MainActor () -> Void)?

    init?(session: DocumentSession)
    {
        guard let projection = WritingProjection(session.state)
        else
        {
            return nil
        }
        self.session = session
        self.projection = projection
    }

    @discardableResult
    func project(in view: NSTextView) -> Bool
    {
        guard view.textLayoutManager != nil, view.textStorage != nil,
              let next = WritingProjection(session.state),
              let presentation = WritingTextPresentation(next)
        else
        {
            return false
        }
        projecting = true
        defer
        {
            projecting = false
            didChange?()
        }
        projection = next
        let marked = composition != nil || view.hasMarkedText()
        composition = nil
        composing = true
        if marked
        {
            view.unmarkText()
            view.inputContext?.discardMarkedText()
        }
        presentation.replace(in: view)
        view.setSelectedRange(next.selection)
        view.scrollRangeToVisible(next.selection)
        composing = false
        return true
    }
}
