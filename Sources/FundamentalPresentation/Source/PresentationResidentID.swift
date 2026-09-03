import Foundation

package struct PresentationResidentID: Equatable, Hashable, Sendable
{
    package let blockID: UUID
    package let blockOrdinal: Int
    package let fragmentOrdinal: Int

    package init?(
        blockID: UUID,
        blockOrdinal: Int,
        fragmentOrdinal: Int
    )
    {
        guard blockOrdinal >= 0,
              fragmentOrdinal >= 0
        else
        {
            return nil
        }
        self.blockID = blockID
        self.blockOrdinal = blockOrdinal
        self.fragmentOrdinal = fragmentOrdinal
    }
}
