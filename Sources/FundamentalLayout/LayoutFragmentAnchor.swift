import Foundation
import FundamentalProjection

package struct LayoutFragmentAnchor: Equatable, Hashable, Sendable
{
    package let blockID: UUID
    package let blockOrdinal: Int
    package let fragmentOrdinal: Int

    init(
        source: ProjectedBlockSource,
        fragmentOrdinal: Int
    )
    {
        blockID = source.blockID
        blockOrdinal = source.ordinal
        self.fragmentOrdinal = fragmentOrdinal
    }
}
