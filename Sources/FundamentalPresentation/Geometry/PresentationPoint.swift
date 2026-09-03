package struct PresentationPoint: Equatable, Sendable
{
    package let x: Double
    package let y: Double

    package init?(x: Double, y: Double)
    {
        guard x.isFinite,
              y.isFinite
        else
        {
            return nil
        }
        self.x = x == 0 ? 0 : x
        self.y = y == 0 ? 0 : y
    }
}
