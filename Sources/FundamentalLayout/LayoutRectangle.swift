package struct LayoutRectangle: Equatable, Sendable
{
    package let origin: LayoutPoint
    package let size: LayoutSize

    package init?(
        origin: LayoutPoint,
        size: LayoutSize
    )
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

    package func intersects(_ other: LayoutRectangle) -> Bool
    {
        minX < other.maxX &&
            other.minX < maxX &&
            minY < other.maxY &&
            other.minY < maxY
    }
}
