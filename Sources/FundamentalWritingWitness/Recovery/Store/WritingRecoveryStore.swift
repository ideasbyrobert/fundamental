import Foundation

actor WritingRecoveryStore
{
    let directory: URL
    let codec = WritingRecoveryCodec()
    var admissions: [UUID: WritingRecoveryAdmission] = [:]

    init(directory: URL)
    {
        self.directory = directory
    }

    @discardableResult
    func checkpoint(_ record: WritingRecoveryRecord) throws -> Bool
    {
        try prepareDirectory()
        let location = location(record.identifier)
        var admission = try admission(for: record.identifier)
        guard admission.admit(record)
        else
        {
            return false
        }
        admissions[record.identifier] = admission
        let data = try codec.encode(record)
        try validateFileIfPresent(location)
        try data.write(to: location, options: .atomic)
        return true
    }

    @discardableResult
    func saved(_ identifier: UUID, revision: UInt64) throws -> Bool
    {
        try prepareDirectory()
        var admission = try admission(for: identifier)
        admission.saved(revision)
        admissions[identifier] = admission
        let file = location(identifier)
        guard let record = try readIfPresent(file), record.revision == revision
        else
        {
            return false
        }
        try FileManager.default.removeItem(at: file)
        return true
    }

    func discard(_ identifier: UUID) throws
    {
        try prepareDirectory()
        var admission = admissions[identifier] ?? WritingRecoveryAdmission()
        admission.discarded = true
        admissions[identifier] = admission
        let file = location(identifier)
        try validateFileIfPresent(file)
        if FileManager.default.fileExists(atPath: file.path)
        {
            try FileManager.default.removeItem(at: file)
        }
    }

    func admission(for identifier: UUID) throws -> WritingRecoveryAdmission
    {
        if let admission = admissions[identifier]
        {
            return admission
        }
        var admission = WritingRecoveryAdmission()
        if let record = try readIfPresent(location(identifier))
        {
            _ = admission.admit(record)
        }
        return admission
    }

    func location(_ identifier: UUID) -> URL
    {
        directory.appending(path: identifier.uuidString + ".recovery")
    }
}
