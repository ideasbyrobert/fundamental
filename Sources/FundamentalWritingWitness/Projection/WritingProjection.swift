import Foundation
import FundamentalDocument

struct WritingProjection: Equatable, Sendable
{
    let snapshot: EditableDocumentSnapshot
    let text: String
    let selection: NSRange

    init?(_ state: DocumentSessionState)
    {
        guard case let .editable(editable) = state
        else
        {
            return nil
        }
        let blocks = editable.snapshot.document.content.blocks
        guard blocks.count == 1,
              case let .paragraph(paragraph) = blocks[0].block
        else
        {
            return nil
        }
        var count = 0
        for run in paragraph.runs
        {
            guard case .direct = run,
                  run.traits.isEmpty,
                  WritingSurfacePolicy.admits(run.text)
            else
            {
                return nil
            }
            let (next, overflow) = count.addingReportingOverflow(
                run.text.utf16.count
            )
            guard !overflow, next <= WritingSurfacePolicy.maximumUTF16Units
            else
            {
                return nil
            }
            count = next
        }
        let start = editable.selection.range.start.utf16Offset.value
        let end = editable.selection.range.end.utf16Offset.value
        snapshot = editable
        text = paragraph.runs.map(\.text).joined()
        selection = NSRange(location: min(start, end), length: abs(end - start))
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
        guard native.location >= 0, native.length >= 0, !overflow,
              end <= text.utf16.count,
              let lower = DocumentUTF16Offset(native.location),
              let upper = DocumentUTF16Offset(end)
        else
        {
            return nil
        }
        let document = snapshot.snapshot.document
        let blockID = document.content.blocks[0].blockID
        return DocumentRange(
            start: DocumentPoint(
                documentID: document.documentID,
                revision: document.revision,
                blockID: blockID,
                utf16Offset: lower
            ),
            end: DocumentPoint(
                documentID: document.documentID,
                revision: document.revision,
                blockID: blockID,
                utf16Offset: upper
            )
        )
    }
}
