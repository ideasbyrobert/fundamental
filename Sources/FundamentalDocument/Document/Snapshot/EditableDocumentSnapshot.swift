package struct EditableDocumentSnapshot: Equatable, Sendable
{
    package let snapshot: DocumentSnapshot
    package let selection: DocumentSelection
    package let typingIntent: DocumentTypingIntent?

    package init?(
        snapshot: DocumentSnapshot,
        selection: DocumentSelection,
        typingIntent: DocumentTypingIntent? = nil
    )
    {
        for block in snapshot.document.content.blocks
        {
            guard EditableSemanticBlock(block.block) != nil
            else
            {
                return nil
            }
        }

        guard (typingIntent == nil || selection.range.isCollapsed),
              ResolvedDocumentRange(
            selection.range,
            in: snapshot.document
        ) != nil
        else
        {
            return nil
        }

        self.snapshot = snapshot
        self.selection = selection
        self.typingIntent = typingIntent
    }
}
