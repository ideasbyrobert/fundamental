package struct RasterPixelBounds: Equatable, Sendable
{
    package let minimumX: Int
    package let minimumY: Int
    package let maximumX: Int
    package let maximumY: Int
    package let width: Int
    package let height: Int
    package let area: Int

    package init?(
        logicalBounds: RasterRectangle,
        backingScale: Double
    )
    {
        let scaled = [
            logicalBounds.minX * backingScale,
            logicalBounds.minY * backingScale,
            logicalBounds.maxX * backingScale,
            logicalBounds.maxY * backingScale
        ]
        guard backingScale.isFinite,
              backingScale > 0,
              scaled.allSatisfy(\.isFinite),
              let minimumX = Int(exactly: scaled[0].rounded(.down)),
              let minimumY = Int(exactly: scaled[1].rounded(.down)),
              let maximumX = Int(exactly: scaled[2].rounded(.up)),
              let maximumY = Int(exactly: scaled[3].rounded(.up))
        else
        {
            return nil
        }
        let (width, widthOverflow) = maximumX.subtractingReportingOverflow(
            minimumX
        )
        let (height, heightOverflow) = maximumY.subtractingReportingOverflow(
            minimumY
        )
        let (area, areaOverflow) = width.multipliedReportingOverflow(
            by: height
        )
        guard !widthOverflow,
              !heightOverflow,
              !areaOverflow,
              width > 0,
              height > 0,
              area > 0
        else
        {
            return nil
        }
        self.minimumX = minimumX
        self.minimumY = minimumY
        self.maximumX = maximumX
        self.maximumY = maximumY
        self.width = width
        self.height = height
        self.area = area
    }
}
