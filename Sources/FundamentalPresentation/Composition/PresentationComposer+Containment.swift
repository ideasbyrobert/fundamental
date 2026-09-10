extension PresentationComposer
{
    static func contains(
        _ outer: PresentationRectangle,
        _ inner: PresentationRectangle
    ) -> Bool
    {
        inner.minX >= outer.minX
            && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX
            && inner.maxY <= outer.maxY
    }
}
