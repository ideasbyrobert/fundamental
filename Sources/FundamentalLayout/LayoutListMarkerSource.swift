import FundamentalProjection

package struct LayoutListMarkerSource: Equatable, Sendable
{
    package let block: ProjectedBlockSource
    package let position: ProjectedListPosition
    private let numbered: Bool

    package var role: ProjectedProseRole
    {
        numbered ? .numbered(position) : .bulleted(position)
    }

    package var label: String
    {
        numbered ? "\(position.number)." : "•"
    }

    package init?(block: ProjectedBlockSource, role: ProjectedProseRole)
    {
        switch role
        {
        case let .bulleted(position):
            self.position = position
            numbered = false
        case let .numbered(position):
            self.position = position
            numbered = true
        default:
            return nil
        }
        self.block = block
    }
}
