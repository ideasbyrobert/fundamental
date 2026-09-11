extension WrappingSource
{
    package func boundaryIndex(atOrBefore offset: Int) -> Int
    {
        var lower = 0
        var upper = graphemeBoundaries.count
        while lower < upper
        {
            let middle = lower + (upper - lower) / 2
            if graphemeBoundaries[middle] <= offset
            {
                lower = middle + 1
            }
            else
            {
                upper = middle
            }
        }
        return max(0, lower - 1)
    }
}
