package struct DocumentTypingIntent: Equatable, Sendable
{
    package let attributes: SemanticRunAttributes

    package init(attributes: SemanticRunAttributes)
    {
        self.attributes = attributes
    }
}
