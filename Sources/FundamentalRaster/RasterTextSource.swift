import Foundation

package enum RasterTextSource: Equatable, Sendable
{
    case block(
        blockID: UUID,
        run: Int,
        range: Range<Int>
    )
    case caption(
        blockID: UUID,
        run: Int,
        range: Range<Int>
    )
    case cell(
        blockID: UUID,
        row: Int,
        cell: Int,
        run: Int,
        range: Range<Int>
    )
}
