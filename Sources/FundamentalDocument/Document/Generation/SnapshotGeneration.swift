struct SnapshotGeneration: Comparable, Sendable
{
    static let zero = SnapshotGeneration(0)

    let value: UInt64

    init(_ value: UInt64)
    {
        self.value = value
    }

    init?(after generation: SnapshotGeneration)
    {
        guard generation.value < UInt64.max
        else
        {
            return nil
        }

        value = generation.value + 1
    }

    static func < (
        lhs: SnapshotGeneration,
        rhs: SnapshotGeneration
    ) -> Bool
    {
        lhs.value < rhs.value
    }
}
