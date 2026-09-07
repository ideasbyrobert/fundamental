import Foundation

extension DocumentFileWriter
{
    func publish(
        _ candidate: DocumentFileCandidate,
        previous: DocumentFileRead?,
        bytes: Data
    ) throws -> DocumentFileSaveReceipt
    {
        do
        {
            let installed: DocumentFileLocation
            switch condition
            {
            case .absent:
                installed = try publishNew(candidate)
            case .unchanged:
                installed = try replaceExisting(candidate)
            }
            let file = try verify(
                installed: installed,
                previous: previous,
                bytes: bytes,
                candidate: candidate
            )
            return DocumentFileSaveReceipt(
                file: file, retainedItems: candidate.discard()
            )
        }
        catch
        {
            guard candidate.preserved
            else
            {
                throw error
            }
            throw DocumentFileFailure.unconfirmedWrite(DocumentFileRecovery(
                destination: location,
                locations: candidate.recoveryLocations,
                error: error
            ))
        }
    }
}
