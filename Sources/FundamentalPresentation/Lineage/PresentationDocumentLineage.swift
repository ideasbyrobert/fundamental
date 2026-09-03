import Foundation

package struct PresentationDocumentLineage: Equatable, Sendable
{
    package let documentID: UUID
    package let revision: UInt64
    package let projectionGeneration: UInt64
}
