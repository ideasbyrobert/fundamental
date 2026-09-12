import Foundation

extension WritingRecoveryStore
{
    func prepareDirectory() throws
    {
        try FileManager.default.createDirectory(
            at: directory, withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )
        let values = try directory.resourceValues(forKeys:
            [.isDirectoryKey, .isSymbolicLinkKey])
        guard values.isDirectory == true, values.isSymbolicLink != true
        else
        {
            throw WritingRecoveryFailure.unsafeLocation
        }
    }

    func validateFileIfPresent(_ file: URL) throws
    {
        let values: URLResourceValues
        do
        {
            values = try file.resourceValues(forKeys: [
                .isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey
            ])
        }
        catch let error as CocoaError where error.code == .fileReadNoSuchFile
        {
            return
        }
        guard values.isRegularFile == true, values.isSymbolicLink != true
        else
        {
            throw WritingRecoveryFailure.unsafeLocation
        }
        guard let size = values.fileSize,
              size <= WritingRecoveryCodec.maximumBytes
        else
        {
            throw WritingRecoveryFailure.oversizedRecord
        }
    }

    func readIfPresent(_ file: URL) throws -> WritingRecoveryRecord?
    {
        try validateFileIfPresent(file)
        let data: Data
        do
        {
            data = try Data(contentsOf: file)
        }
        catch let error as CocoaError where error.code == .fileReadNoSuchFile
        {
            return nil
        }
        let record = try codec.decode(data)
        let expected = record.identifier.uuidString + ".recovery"
        guard file.lastPathComponent == expected
        else
        {
            throw WritingRecoveryFailure.invalidRecord
        }
        return record
    }
}
