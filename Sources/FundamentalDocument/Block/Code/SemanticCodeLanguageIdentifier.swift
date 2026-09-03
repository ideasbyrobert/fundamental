package struct SemanticCodeLanguageIdentifier: Equatable, Sendable
{
    package let value: String

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
