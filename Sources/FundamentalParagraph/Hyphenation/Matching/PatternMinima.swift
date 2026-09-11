package struct PatternMinima: Equatable, Sendable
{
    package let left: Int
    package let right: Int

    package init(left: Int, right: Int) throws(PatternFailure)
    {
        guard left > 0, right > 0
        else
        {
            throw .invalidMinima
        }
        self.left = left
        self.right = right
    }

    package func allows(_ index: Int, count: Int) -> Bool
    {
        index >= left && count - index >= right
    }
}
