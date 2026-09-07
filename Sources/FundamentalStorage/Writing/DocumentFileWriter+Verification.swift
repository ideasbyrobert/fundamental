import CryptoKit
import Foundation

extension DocumentFileWriter
{
    func verify(
        installed: DocumentFileLocation,
        previous: DocumentFileRead?,
        bytes: Data,
        candidate: DocumentFileCandidate
    ) throws -> DocumentFileRead
    {
        if let previous
        {
            guard let backupURL = candidate.backupURL,
                  let backup = DocumentFileLocation(backupURL)
            else
            {
                throw DocumentFileFailure.invalidLocation
            }
            let retained = try DocumentFileReader(
                location: backup, codec: codec
            ).read()
            guard retained.revision.digest == previous.revision.digest
            else
            {
                throw DocumentFileFailure.conflictingRevision
            }
        }
        let read = try DocumentFileReader(
            location: installed, codec: codec
        ).read()
        guard read.revision.digest == Data(SHA256.hash(data: bytes))
        else
        {
            throw DocumentFileFailure.changedDuringRead
        }
        return read
    }
}
