struct DocumentRevision: Comparable, Sendable
{
    static let zero = DocumentRevision(0)

    let value: UInt64

    init(_ value: UInt64)
    {
        self.value = value
    }

    init?(after revision: DocumentRevision)
    {
        guard revision.value < UInt64.max
        else
        {
            return nil
        }

        value = revision.value + 1
    }

    static func < (
        lhs: DocumentRevision,
        rhs: DocumentRevision
    ) -> Bool
    {
        lhs.value < rhs.value
    }
}
