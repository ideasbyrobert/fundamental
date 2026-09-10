package struct DocumentInputTransaction: Equatable, Sendable
{
    let edit: CanonicalDocumentEdit?
    let selection: DocumentSelection
    let typingIntent: DocumentTypingIntent?

    package init(
        edit: CanonicalDocumentEdit? = nil, selection: DocumentSelection,
        typingIntent: DocumentTypingIntent? = nil
    )
    {
        self.edit = edit
        self.selection = selection
        self.typingIntent = typingIntent
    }
}
