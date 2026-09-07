import Foundation

extension DocumentSession
{
    package var isDirty: Bool
    {
        persistence.savedContentRevision != persistence.contentRevision
    }

    package var hasPendingSave: Bool
    {
        persistence.latestRequestID != nil
    }

    package func prepareSave() -> DocumentSaveTicket
    {
        let requestID = UUID()
        persistence.latestRequestID = requestID
        return DocumentSaveTicket(
            sessionID: persistence.sessionID,
            requestID: requestID,
            contentRevision: persistence.contentRevision,
            document: document
        )
    }

    @discardableResult
    package func acknowledgeSave(_ ticket: DocumentSaveTicket) -> Bool
    {
        guard ticket.sessionID == persistence.sessionID,
              ticket.requestID == persistence.latestRequestID,
              ticket.document.documentID == document.documentID
        else
        {
            return false
        }
        persistence.savedContentRevision = ticket.contentRevision
        persistence.latestRequestID = nil
        return true
    }

    @discardableResult
    package func abandonSave(_ ticket: DocumentSaveTicket) -> Bool
    {
        guard ticket.sessionID == persistence.sessionID,
              ticket.requestID == persistence.latestRequestID
        else
        {
            return false
        }
        persistence.latestRequestID = nil
        return true
    }
}
