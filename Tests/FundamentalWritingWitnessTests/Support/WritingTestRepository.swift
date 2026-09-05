import Foundation

struct WritingTestRepository
{
    static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()

    static func source(_ path: String) throws -> String
    {
        try String(contentsOf: root.appending(path: path), encoding: .utf8)
    }
}
