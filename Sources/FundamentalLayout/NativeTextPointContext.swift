import Foundation

enum NativeTextPointContext
{
    case block(UUID)
    case caption(UUID)
    case cell(
        blockID: UUID,
        row: Int,
        cell: Int
    )
}
