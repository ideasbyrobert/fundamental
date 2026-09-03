import Foundation

package struct ProjectionLineage: Equatable, Sendable
{
    package let documentID: UUID
    package let revision: UInt64
    package let generation: UInt64
}
