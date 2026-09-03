package struct PresentationColor: Equatable, Sendable
{
    package let colorSpace: PresentationColorSpaceIdentity
    package let components: [Double]
    package let alpha: Double

    package init?(
        colorSpace: PresentationColorSpaceIdentity,
        components: [Double],
        alpha: Double
    )
    {
        guard components.count == colorSpace.componentCount,
              components.allSatisfy(\.isFinite),
              components.allSatisfy(
              {
                  0 ... 1 ~= $0
              }),
              alpha.isFinite,
              0 ... 1 ~= alpha
        else
        {
            return nil
        }
        self.colorSpace = colorSpace
        self.components = components.map
        {
            $0 == 0 ? 0 : $0
        }
        self.alpha = alpha == 0 ? 0 : alpha
    }
}
