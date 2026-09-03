import FundamentalRaster

extension PresentationComposer
{
    static func point(
        _ value: RasterPoint
    ) -> PresentationPoint?
    {
        PresentationPoint(x: value.x, y: value.y)
    }

    static func size(
        _ value: RasterSize
    ) -> PresentationSize?
    {
        PresentationSize(
            width: value.width,
            height: value.height
        )
    }

    static func rectangle(
        _ value: RasterRectangle
    ) -> PresentationRectangle?
    {
        rectangle(
            x: value.minX,
            y: value.minY,
            width: value.size.width,
            height: value.size.height
        )
    }

    static func rectangle(
        x: Double,
        y: Double,
        width: Double,
        height: Double
    ) -> PresentationRectangle?
    {
        guard let origin = PresentationPoint(x: x, y: y),
              let size = PresentationSize(
                  width: width,
                  height: height
              )
        else
        {
            return nil
        }
        return PresentationRectangle(origin: origin, size: size)
    }

    static func vector(
        _ value: RasterVector
    ) -> PresentationVector?
    {
        PresentationVector(dx: value.dx, dy: value.dy)
    }

    static func transform(
        _ value: RasterAffineTransform
    ) -> PresentationAffineTransform?
    {
        transform(
            a: value.a,
            b: value.b,
            c: value.c,
            d: value.d,
            tx: value.tx,
            ty: value.ty
        )
    }

    static func transform(
        a: Double,
        b: Double,
        c: Double,
        d: Double,
        tx: Double,
        ty: Double
    ) -> PresentationAffineTransform?
    {
        PresentationAffineTransform(
            a: a,
            b: b,
            c: c,
            d: d,
            tx: tx,
            ty: ty
        )
    }

    static func pixelBounds(
        _ value: RasterPixelBounds,
        logicalBounds: PresentationRectangle,
        backingScale: Double
    ) -> PresentationPixelBounds?
    {
        guard let bounds = PresentationPixelBounds(
            logicalBounds: logicalBounds,
            backingScale: backingScale
        ),
              bounds.minimumX == value.minimumX,
              bounds.minimumY == value.minimumY,
              bounds.maximumX == value.maximumX,
              bounds.maximumY == value.maximumY,
              bounds.width == value.width,
              bounds.height == value.height,
              bounds.area == value.area
        else
        {
            return nil
        }
        return bounds
    }
}
