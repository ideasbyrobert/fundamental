import FundamentalViewport

struct RasterLineGeometry
{
    let bounds: RasterRectangle
    let baseline: RasterPoint
    let clip: RasterRectangle
    let pixels: RasterPixelBounds

    init?(
        line: ResidentLayoutLine, frame: RasterRectangle,
        target: RasterRectangle, scale: Double
    )
    {
        guard let bounds = ViewportRasterizer.rectangle(
            x: line.frame.minX, y: line.frame.minY,
            width: line.frame.size.width, height: line.frame.size.height
        ),
              let baseline = RasterPoint(
                  x: line.baseline.x, y: line.baseline.y
              ),
              let clip = frame.intersection(target),
              let pixels = RasterPixelBounds(
                  logicalBounds: clip, backingScale: scale
              )
        else
        {
            return nil
        }
        self.bounds = bounds
        self.baseline = baseline
        self.clip = clip
        self.pixels = pixels
    }
}
