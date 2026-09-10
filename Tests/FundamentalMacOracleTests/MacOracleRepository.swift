import Foundation

enum MacOracleRepository
{
    static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()

    static func source(
        _ path: String
    ) throws -> String
    {
        try String(
            contentsOf: root.appending(path: path),
            encoding: .utf8
        )
    }

    static func swiftSources(
        _ path: String, excluding: String? = nil
    ) throws -> [String]
    {
        let directory = root.appending(path: path)
        let excluded = excluding.map
        {
            root.appending(path: $0).standardizedFileURL
        }
        let keys: [URLResourceKey] = [.isRegularFileKey]
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: keys
        )
        else
        {
            throw MacOracleTestFailure.admission
        }
        return try enumerator.compactMap
        {
            guard let url = $0 as? URL,
                  url.standardizedFileURL != excluded,
                  url.pathExtension == "swift",
                  try url.resourceValues(forKeys: Set(keys))
                    .isRegularFile == true
            else
            {
                return nil
            }
            return try String(contentsOf: url, encoding: .utf8)
        }
    }
}
