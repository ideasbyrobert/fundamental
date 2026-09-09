extension EditableDocumentSnapshot
{
    package func typingAttributes(
        in range: DocumentRange
    ) -> SemanticRunAttributes?
    {
        if range == selection.range, let typingIntent
        {
            return typingIntent.attributes
        }
        return InheritedTypingAttributes(
            range, in: snapshot.document
        )?.attributes
    }
}
