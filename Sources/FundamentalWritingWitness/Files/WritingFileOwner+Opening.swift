import FundamentalDocument
import FundamentalStorage

extension WritingFileOwner
{
    static func open(
        _ location: DocumentFileLocation,
        storage: any WritingDocumentStorage = DocumentFileStore()
    ) async throws -> WritingFileOwner
    {
        let file = try await storage.read(location)
        guard let seed = WritingDocumentSeed(document: file.document),
              WritingProjection(seed.state) != nil
        else
        {
            throw WritingFileFailure.unsupportedDocument
        }
        let owner = WritingFileOwner(
            session: DocumentSession(state: seed.state, initiallySaved: true),
            storage: storage
        )
        owner.binding = WritingFileBinding(file)
        return owner
    }
}
