import FundamentalLayout

package struct ResidentLayoutFragment: Equatable, Sendable
{
    package let residence: ViewportResidence
    package let fragment: LayoutFragment

    var canAnchor: Bool
    {
        guard case let .grid(fragment) = fragment,
              case .rule = fragment.content
        else
        {
            return true
        }
        return false
    }
}
