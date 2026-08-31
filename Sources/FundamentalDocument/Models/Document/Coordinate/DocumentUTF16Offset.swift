struct DocumentUTF16Offset: Comparable, Sendable
{
    let value: Int

    init?(_ value: Int)
    {
        guard value >= 0
        else
        {
            return nil
        }

        self.value = value
    }

    static func < (
        lhs: DocumentUTF16Offset,
        rhs: DocumentUTF16Offset
    ) -> Bool
    {
        lhs.value < rhs.value
    }
}
