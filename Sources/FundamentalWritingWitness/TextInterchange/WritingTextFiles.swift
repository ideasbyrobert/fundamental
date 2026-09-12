import Foundation

actor WritingTextFiles
{
    static let shared = WritingTextFiles()

    func read(_ location: URL) throws -> WritingTextImport
    {
        try WritingTextImport(bytes(at: location))
    }

    func write(_ data: Data, to location: URL, protecting source: URL?) throws
    {
        guard location.isFileURL,
              !["fun", "fundamental"].contains(
                  location.pathExtension.lowercased()
              ), location.resolvingSymlinksInPath() !=
                source?.resolvingSymlinksInPath()
        else
        {
            throw WritingTextFailure.invalidLocation
        }
        guard data.count <= WritingTextImport.maximumBytes
        else
        {
            throw WritingTextFailure.excessiveText
        }
        if FileManager.default.fileExists(atPath: location.path)
        {
            try validate(location)
        }
        try data.write(to: location, options: .atomic)
        guard try bytes(at: location) == data
        else
        {
            throw WritingTextFailure.unconfirmedExport
        }
    }

    private func bytes(at location: URL) throws -> Data
    {
        try validate(location)
        let handle = try FileHandle(forReadingFrom: location)
        defer { try? handle.close() }
        let limit = WritingTextImport.maximumBytes
        var bytes = Data()
        while bytes.count <= limit
        {
            let remaining = min(65_536, limit + 1 - bytes.count)
            guard let part = try handle.read(upToCount: remaining),
                  !part.isEmpty
            else
            {
                return bytes
            }
            bytes.append(part)
        }
        throw WritingTextFailure.excessiveText
    }

    private func validate(_ location: URL) throws
    {
        guard location.isFileURL
        else
        {
            throw WritingTextFailure.invalidLocation
        }
        let values = try location.resourceValues(forKeys: [
            .isRegularFileKey, .isSymbolicLinkKey
        ])
        guard values.isRegularFile == true, values.isSymbolicLink != true
        else
        {
            throw WritingTextFailure.invalidLocation
        }
    }
}
