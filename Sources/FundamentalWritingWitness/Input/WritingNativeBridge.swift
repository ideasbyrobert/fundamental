import AppKit
import FundamentalDocument

@MainActor
final class WritingNativeBridge: NSObject, NSTextViewDelegate
{
    let session: DocumentSession
    var projection: WritingProjection
    var projecting = false
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
        guard view.textLayoutManager != nil,
              let next = WritingProjection(session.state)
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
        view.string = next.text
        view.setSelectedRange(next.selection)
        view.scrollRangeToVisible(next.selection)
        return true
    }
}
