import Foundation

package struct DocumentSaveTicket: Sendable
{
    let sessionID: UUID
    let requestID: UUID
    let contentRevision: DocumentRevision
    package let document: CanonicalDocument
}
