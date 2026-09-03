package struct SemanticTableRowIndex: Equatable, Sendable
{
    package let value: Int

    init?(_ value: Int)
    {
        guard value >= 0
        else
        {
            return nil
        }

        self.value = value
    }
}
