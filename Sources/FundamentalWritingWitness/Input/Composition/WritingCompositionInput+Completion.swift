import Foundation
import FundamentalDocument

extension WritingCompositionInput
{
    static func complete(
        _ selection: NSRange, in projection: WritingProjection,
        attributes: SemanticRunAttributes, previous: EditableDocumentSnapshot
    ) -> EditableDocumentSnapshot?
    {
        let destination = projection.snapshot
        let requested = projection.range(selection).flatMap
        {
            EditableDocumentSnapshot(snapshot: destination.snapshot,
                                     selection: DocumentSelection(range: $0))
        }
        guard let plain = requested ?? EditableDocumentSnapshot(
            snapshot: destination.snapshot, selection: destination.selection
        )
        else
        {
            return nil
        }
        var intent: DocumentTypingIntent? = nil
        if plain.selection.range.start == plain.selection.range.end
        {
            guard let inherited = plain.typingAttributes(
                in: plain.selection.range
            )
            else
            {
                return nil
            }
            let candidate = DocumentTypingIntent(attributes: attributes)
            if previous.typingIntent != nil ||
                candidate != DocumentTypingIntent(attributes: inherited)
            {
                intent = candidate
            }
        }
        return EditableDocumentSnapshot(snapshot: plain.snapshot,
            selection: plain.selection, typingIntent: intent)
    }
}
