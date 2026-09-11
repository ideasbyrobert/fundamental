import Foundation

extension ViewportWindowFixture
{
    static var repositoryRoot: URL
    {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    static func source(
        target: String,
        file: String
    ) throws -> String
    {
        try String(
            contentsOf: repositoryRoot
                .appendingPathComponent("Sources")
                .appendingPathComponent(target)
                .appendingPathComponent(file),
            encoding: .utf8
        )
    }
}
