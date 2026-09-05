package struct EditableDocumentSnapshot: Equatable, Sendable
{
    package let snapshot: DocumentSnapshot
    package let selection: DocumentSelection

    package init?(
        snapshot: DocumentSnapshot,
        selection: DocumentSelection
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

        guard ResolvedDocumentRange(
            selection.range,
            in: snapshot.document
        ) != nil
        else
        {
            return nil
        }

        self.snapshot = snapshot
        self.selection = selection
    }
}
