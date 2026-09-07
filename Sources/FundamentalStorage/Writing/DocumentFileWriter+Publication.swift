import Darwin
import Foundation

extension DocumentFileWriter
{
    func publishNew(
        _ candidate: DocumentFileCandidate
    ) throws -> DocumentFileLocation
    {
        guard renamex_np(
            candidate.url.path, location.path, UInt32(RENAME_EXCL)
        ) == 0
        else
        {
            let failure = errno
            if failure == EEXIST
            {
                throw DocumentFileFailure.destinationExists
            }
            throw DocumentFileFailure.fileSystem(failure)
        }
        candidate.preserved = true
        return location
    }

    func replaceExisting(
        _ candidate: DocumentFileCandidate
    ) throws -> DocumentFileLocation
    {
        let backup = try candidate.reserveBackup(at: location)
        candidate.preserved = true
        let result = try FileManager.default.replaceItemAt(
            location.url,
            withItemAt: candidate.url,
            backupItemName: backup.lastPathComponent,
            options: .withoutDeletingBackupItem
        )
        guard let installed = DocumentFileLocation(result ?? location.url)
        else
        {
            throw DocumentFileFailure.invalidLocation
        }
        return installed
    }
}
