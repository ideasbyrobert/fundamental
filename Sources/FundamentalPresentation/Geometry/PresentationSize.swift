package struct PresentationSize: Equatable, Sendable
{
    package let width: Double
    package let height: Double

    package init?(width: Double, height: Double)
    {
        guard width.isFinite,
              height.isFinite,
              width >= 0,
              height >= 0
        else
        {
            return nil
        }
        self.width = width == 0 ? 0 : width
        self.height = height == 0 ? 0 : height
    }
}
