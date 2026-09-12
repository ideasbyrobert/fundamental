import Foundation

struct WritingRecoveryCatalog: Sendable
{
    let records: [WritingRecoveryRecord]
    let unreadable: [URL]
}

extension WritingRecoveryStore
{
    func catalog() throws -> WritingRecoveryCatalog
    {
        try prepareDirectory()
        let files = try FileManager.default.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ).filter { $0.pathExtension == "recovery" }
        var records: [WritingRecoveryRecord] = []
        var unreadable: [URL] = []
        for file in files.sorted(by: { $0.path < $1.path })
        {
            do
            {
                if let record = try readIfPresent(file)
                {
                    records.append(record)
                }
            }
            catch
            {
                unreadable.append(file)
            }
        }
        return WritingRecoveryCatalog(records: records, unreadable: unreadable)
    }
}
