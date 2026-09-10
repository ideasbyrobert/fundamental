import Foundation
import FundamentalDocument

struct WritingProjection: Equatable, Sendable
{
    let snapshot: EditableDocumentSnapshot
    let map: WritingParagraphMap
    let selection: NSRange

    init?(_ state: DocumentSessionState)
    {
        guard case let .editable(editable) = state,
              let map = WritingParagraphMap(
                  blocks: editable.snapshot.document.content.blocks
              ),
              let start = map.offset(editable.selection.range.start),
              let end = map.offset(editable.selection.range.end)
        else
        {
            return nil
        }
        snapshot = editable
        self.map = map
        selection = NSRange(location: min(start, end), length: abs(end - start))
    }

    var text: String
    {
        map.text
    }

    var observation: DocumentObservation
    {
        DocumentObservation(snapshot: snapshot.snapshot)
    }

    func range(_ native: NSRange) -> DocumentRange?
    {
        let (end, overflow) = native.location.addingReportingOverflow(
            native.length
        )
        let document = snapshot.snapshot.document
        guard native.location >= 0, native.length >= 0, !overflow,
              let lower = map.point(native.location, in: document),
              let upper = map.point(end, in: document)
        else
        {
            return nil
        }
        return DocumentRange(start: lower, end: upper)
    }
}
