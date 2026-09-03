package struct PresentationVector: Equatable, Sendable
{
    package let dx: Double
    package let dy: Double

    package init?(dx: Double, dy: Double)
    {
        guard dx.isFinite,
              dy.isFinite
        else
        {
            return nil
        }
        self.dx = dx == 0 ? 0 : dx
        self.dy = dy == 0 ? 0 : dy
    }
}
