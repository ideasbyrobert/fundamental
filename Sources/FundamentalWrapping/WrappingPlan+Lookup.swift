extension WrappingPlan
{
    package func line(startingAt offset: Int) -> WrappingLineChoice?
    {
        var lower = 0
        var upper = lines.count
        while lower < upper
        {
            let middle = lower + (upper - lower) / 2
            let line = lines[middle]
            if line.range.lowerBound == offset
            {
                return line
            }
            if line.range.lowerBound < offset
            {
                lower = middle + 1
            }
            else
            {
                upper = middle
            }
        }
        return nil
    }
}
