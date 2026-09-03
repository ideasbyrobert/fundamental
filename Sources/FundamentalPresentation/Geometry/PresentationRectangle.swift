package struct PresentationRectangle: Equatable, Sendable
{
    package let origin: PresentationPoint
    package let size: PresentationSize

    package init?(
        origin: PresentationPoint,
        size: PresentationSize
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
}
