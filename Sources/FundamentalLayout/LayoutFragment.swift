import FundamentalProjection

package enum LayoutFragment: Equatable, Sendable
{
    case lines(LayoutLineFragment)
    case grid(LayoutGridFragment)

    package var anchor: LayoutFragmentAnchor
    {
        switch self
        {
        case let .lines(fragment):
            fragment.anchor
        case let .grid(fragment):
            fragment.anchor
        }
    }

    package var source: ProjectedBlockSource
    {
        switch self
        {
        case let .lines(fragment):
            fragment.source
        case let .grid(fragment):
            fragment.source
        }
    }

    package var frame: LayoutRectangle
    {
        switch self
        {
        case let .lines(fragment):
            fragment.frame
        case let .grid(fragment):
            fragment.frame
        }
    }
}
