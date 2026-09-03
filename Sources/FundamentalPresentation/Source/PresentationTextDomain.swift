import Foundation

package enum PresentationTextDomain: Equatable, Sendable
{
    case block(UUID)
    case caption(UUID)
    case cell(blockID: UUID, row: Int, cell: Int)
}
