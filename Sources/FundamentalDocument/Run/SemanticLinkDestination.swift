struct SemanticLinkDestination: Equatable, Sendable
{
    let value: String

    init?(_ value: String)
    {
        guard value.contains(where: { !$0.isWhitespace })
        else
        {
            return nil
        }

        self.value = value
    }
}
