import Foundation

package enum PresentationTextPoint: Equatable, Sendable
{
    case block(blockID: UUID, utf16Offset: Int)
    case caption(blockID: UUID, utf16Offset: Int)
    case cell(
        blockID: UUID,
        row: Int,
        cell: Int,
        utf16Offset: Int
    )
}
