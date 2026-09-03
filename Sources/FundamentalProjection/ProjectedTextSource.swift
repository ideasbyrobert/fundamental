import Foundation

package enum ProjectedTextSource: Equatable, Sendable
{
    case block(
        blockID: UUID,
        run: Int,
        range: ProjectedUTF16Range
    )
    case caption(
        blockID: UUID,
        run: Int,
        range: ProjectedUTF16Range
    )
    case cell(
        blockID: UUID,
        row: Int,
        cell: Int,
        run: Int,
        range: ProjectedUTF16Range
    )
}
