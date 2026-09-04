extension LayoutDocumentExtentIndex
{
    static func place(
        _ measurements: [LayoutBlockMeasurement],
        blockSpacing: Double
    ) -> (
        extents: [LayoutPlacedFragmentExtent],
        maximumX: Double,
        maximumY: Double
    )?
    {
        var extents: [LayoutPlacedFragmentExtent] = []
        var maximumX = 0.0
        var nextY = 0.0
        for (blockIndex, measurement) in measurements.enumerated()
        {
            if blockIndex > 0
            {
                nextY += blockSpacing
                guard nextY.isFinite
                else
                {
                    return nil
                }
            }
            var blockMaximumY = nextY
            for localExtent in measurement.extents
            {
                guard let placed = LayoutPlacedFragmentExtent(
                    localExtent: localExtent,
                    documentOriginY: nextY
                )
                else
                {
                    return nil
                }
                extents.append(placed)
                maximumX = max(maximumX, placed.frame.maxX)
                blockMaximumY = max(blockMaximumY, placed.frame.maxY)
            }
            guard maximumX.isFinite,
                  blockMaximumY.isFinite
            else
            {
                return nil
            }
            nextY = blockMaximumY
        }
        return (extents, maximumX, nextY)
    }
}
