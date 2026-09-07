package struct DocumentRecordLimits: Equatable, Sendable
{
    package let maximumBytes: Int
    package let maximumBlocks: Int

    package init()
    {
        maximumBytes = 64 * 1024 * 1024
        maximumBlocks = 100_000
    }

    package init?(maximumBytes: Int, maximumBlocks: Int)
    {
        guard maximumBytes > 0, maximumBlocks > 0
        else
        {
            return nil
        }
        self.maximumBytes = maximumBytes
        self.maximumBlocks = maximumBlocks
    }
}
