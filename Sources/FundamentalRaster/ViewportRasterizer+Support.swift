import FundamentalViewport

extension ViewportRasterizer
{
    static func targetBounds(
        _ viewport: ViewportSnapshot,
        documentSize: RasterSize
    ) -> RasterRectangle?
    {
        let specification = viewport.lineage.specification
        let requestedMinimumY = specification.visibleBounds.minY
            - specification.precedingOverscanExtent
        let requestedMaximumY = specification.visibleBounds.maxY
            + specification.followingOverscanExtent
        let minimumY = max(
            0,
            min(documentSize.height, requestedMinimumY)
        )
        let maximumY = max(
            0,
            min(documentSize.height, requestedMaximumY)
        )
        return rectangle(
            x: 0,
            y: minimumY,
            width: documentSize.width,
            height: maximumY - minimumY
        )
    }

    static func rectangle(
        x: Double,
        y: Double,
        width: Double,
        height: Double
    ) -> RasterRectangle?
    {
        guard let origin = RasterPoint(x: x, y: y),
              let size = RasterSize(width: width, height: height)
        else
        {
            return nil
        }
        return RasterRectangle(origin: origin, size: size)
    }

    static func transform(
        a: Double,
        b: Double,
        c: Double,
        d: Double,
        tx: Double,
        ty: Double
    ) -> RasterAffineTransform
    {
        RasterAffineTransform(
            a: a,
            b: b,
            c: c,
            d: d,
            tx: tx,
            ty: ty
        )
    }

    static func appendFill(
        residentID: RasterResidentID,
        role: RasterFillRole,
        bounds: RasterRectangle,
        targetBounds: RasterRectangle,
        color: RasterColor,
        sourceSlices: [RasterSourceSlice],
        specification: RasterSpecificationIdentity,
        accumulator: inout RasterAccumulator
    ) -> Bool
    {
        guard let clipBounds = bounds.intersection(targetBounds)
        else
        {
            return true
        }
        guard let pixelBounds = RasterPixelBounds(
            logicalBounds: clipBounds,
            backingScale: specification.backingScale
        )
        else
        {
            return false
        }
        return accumulator.append(RasterFill(
            residentID: residentID,
            role: role,
            logicalBounds: clipBounds,
            pixelBounds: pixelBounds,
            color: color,
            sourceSlices: sourceSlices
        ))
    }

}
