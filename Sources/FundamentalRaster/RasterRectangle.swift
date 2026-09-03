package struct RasterRectangle: Equatable, Sendable
{
    package let origin: RasterPoint
    package let size: RasterSize

    package init?(origin: RasterPoint, size: RasterSize)
    {
        guard (origin.x + size.width).isFinite,
              (origin.y + size.height).isFinite
        else
        {
            return nil
        }
        self.origin = origin
        self.size = size
    }

    package var minX: Double
    {
        origin.x
    }

    package var minY: Double
    {
        origin.y
    }

    package var maxX: Double
    {
        origin.x + size.width
    }

    package var maxY: Double
    {
        origin.y + size.height
    }

    package func intersection(
        _ other: RasterRectangle
    ) -> RasterRectangle?
    {
        let minimumX = max(minX, other.minX)
        let minimumY = max(minY, other.minY)
        let maximumX = min(maxX, other.maxX)
        let maximumY = min(maxY, other.maxY)
        guard maximumX > minimumX,
              maximumY > minimumY,
              let origin = RasterPoint(
                  x: minimumX,
                  y: minimumY
              ),
              let size = RasterSize(
                  width: maximumX - minimumX,
                  height: maximumY - minimumY
              )
        else
        {
            return nil
        }
        return RasterRectangle(origin: origin, size: size)
    }
}
