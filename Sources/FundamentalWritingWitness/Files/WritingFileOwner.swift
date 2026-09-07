import Foundation
import FundamentalDocument
import FundamentalStorage

@MainActor
final class WritingFileOwner
{
    let session: DocumentSession
    let storage: any WritingDocumentStorage
    var binding: WritingFileBinding?
    var retainedItems: [URL] = []
    var didChange: (@MainActor () -> Void)?

    init(
        session: DocumentSession,
        storage: any WritingDocumentStorage = DocumentFileStore()
    )
    {
        self.session = session
        self.storage = storage
    }

    var isSaving: Bool
    {
        session.hasPendingSave
    }
}
