import Foundation

struct DocumentSessionPersistence: Sendable
{
    let sessionID = UUID()
    var latestRequestID: UUID?
    var contentRevision: DocumentRevision
    var savedContentRevision: DocumentRevision?

    init(contentRevision: DocumentRevision, initiallySaved: Bool)
    {
        self.contentRevision = contentRevision
        savedContentRevision = initiallySaved ? contentRevision : nil
    }
}
