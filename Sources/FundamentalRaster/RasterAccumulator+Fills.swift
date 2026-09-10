extension RasterAccumulator
{
    mutating func append(_ fill: RasterFill) -> Bool
    {
        guard let nextMarks = adding(marks.count, 1),
              let nextFills = adding(fillCount, 1),
              let utf16 = sourceSliceUTF16Count(fill.sourceSlices),
              let nextSlices = adding(
                  sourceSliceCount,
                  fill.sourceSlices.count
              ),
              let nextUTF16 = adding(residentUTF16Count, utf16),
              nextMarks <= capacities.marks,
              nextFills <= capacities.fills,
              nextSlices <= capacities.sourceSlices,
              nextUTF16 <= capacities.residentUTF16Units
        else
        {
            return false
        }
        marks.append(.fill(fill))
        fillCount = nextFills
        sourceSliceCount = nextSlices
        residentUTF16Count = nextUTF16
        return true
    }
}
