extension NativeTextKit2Layout
{
    func rectangle(
        x: Double,
        y: Double,
        width: Double,
        height: Double
    ) throws -> LayoutRectangle
    {
        guard let origin = LayoutPoint(x: x, y: y),
              let size = LayoutSize(width: width, height: height),
              let rectangle = LayoutRectangle(
                  origin: origin,
                  size: size
              )
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        return rectangle
    }

    func point(
        x: Double,
        y: Double
    ) throws -> LayoutPoint
    {
        guard let point = LayoutPoint(x: x, y: y)
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        return point
    }
}
