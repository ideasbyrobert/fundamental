package struct ProjectedListPosition: Equatable, Sendable
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
        self.init(validatedIndex: index, count: count)
    }

    static func positions(count: Int) -> [Self]
    {
        guard count > 0
        else
        {
            return []
        }
        return (0 ..< count).map
        {
            Self(validatedIndex: $0, count: count)
        }
    }

    private init(validatedIndex: Int, count: Int)
    {
        index = validatedIndex
        self.count = count
    }
}
