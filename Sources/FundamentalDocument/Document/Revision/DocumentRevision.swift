package struct DocumentRevision: Comparable, Sendable
{
    package static let zero = DocumentRevision(0)

    package let value: UInt64

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

    package static func < (
        lhs: DocumentRevision,
        rhs: DocumentRevision
    ) -> Bool
    {
        lhs.value < rhs.value
    }
}
