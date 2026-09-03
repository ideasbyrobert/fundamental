import Foundation

package struct RasterResidentID: Equatable, Hashable, Sendable
{
    package let blockID: UUID
    package let blockOrdinal: Int
    package let fragmentOrdinal: Int
}
