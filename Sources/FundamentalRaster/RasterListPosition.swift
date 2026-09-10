package struct RasterListPosition: Equatable, Sendable
{
    package let index: Int
    package let count: Int

    package var number: Int
    {
        index + 1
    }

    package init?(index: Int, count: Int)
    {
        guard index >= 0, count > 0, index < count
        else
        {
            return nil
        }
        self.index = index
        self.count = count
    }
}
