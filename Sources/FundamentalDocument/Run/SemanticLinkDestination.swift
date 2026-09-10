package struct SemanticLinkDestination: Equatable, Sendable
{
    package let value: String

    package init?(_ value: String)
    {
        guard value.contains(where: { !$0.isWhitespace })
        else
        {
            return nil
        }

        self.value = value
    }
}
