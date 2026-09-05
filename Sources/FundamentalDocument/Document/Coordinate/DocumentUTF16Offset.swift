package struct DocumentUTF16Offset: Comparable, Sendable
{
    package let value: Int

    package init?(_ value: Int)
    {
        guard value >= 0
        else
        {
            return nil
        }

        self.value = value
    }

    package static func < (
        lhs: DocumentUTF16Offset,
        rhs: DocumentUTF16Offset
    ) -> Bool
    {
        lhs.value < rhs.value
    }
}
