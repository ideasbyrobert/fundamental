import FundamentalPresentation

extension MacBitmapSurface
{
    func containsInk(
        in bounds: PresentationPixelBounds
    ) -> Bool
    {
        let reference = pixel(x: 0, y: 0)
        return coordinates(in: bounds).contains
        {
            pixel(at: $0) != reference
        }
    }

    func changedPixels(
        from other: MacBitmapSurface,
        in bounds: PresentationPixelBounds
    ) -> Set<Int>
    {
        guard width == other.width,
              height == other.height,
              pixelBounds == other.pixelBounds
        else
        {
            return []
        }
        return Set(coordinates(in: bounds).filter
        {
            pixel(at: $0) != other.pixel(at: $0)
        })
    }

    func pixel(at coordinate: Int) -> UInt32
    {
        pixel(
            x: coordinate % width,
            y: coordinate / width
        )
    }

    private func coordinates(
        in bounds: PresentationPixelBounds
    ) -> [Int]
    {
        let lowerX = max(0, bounds.minimumX - pixelBounds.minimumX)
        let upperX = min(width, bounds.maximumX - pixelBounds.minimumX)
        let lowerY = max(0, bounds.minimumY - pixelBounds.minimumY)
        let upperY = min(height, bounds.maximumY - pixelBounds.minimumY)
        guard lowerX < upperX,
              lowerY < upperY
        else
        {
            return []
        }
        return (lowerY ..< upperY).flatMap
        {
            y in
            (lowerX ..< upperX).map
            {
                (y * width) + $0
            }
        }
    }
}
