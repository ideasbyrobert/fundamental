import Foundation

extension DocumentFileCandidate
{
    func reserveBackup(
        at destination: DocumentFileLocation,
        identity: UUID = UUID()
    ) throws -> URL
    {
        guard backupURL == nil
        else
        {
            throw DocumentFileFailure.destinationExists
        }
        let name = ".Fundamental-\(identity.uuidString)-Previous.fundamental"
        let backup = destination.url.deletingLastPathComponent()
            .appending(path: name)
        try Data().write(to: backup, options: .withoutOverwriting)
        backupURL = backup
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o600], ofItemAtPath: backup.path
        )
        return backup
    }
}
