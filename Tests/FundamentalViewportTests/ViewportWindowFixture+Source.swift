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

    static func source(
        target: String
    ) throws -> String
    {
        let directory = repositoryRoot
            .appendingPathComponent("Sources")
            .appendingPathComponent(target)
        return try FileManager.default.contentsOfDirectory(
            atPath: directory.path
        ).sorted().filter
        {
            $0.hasSuffix(".swift")
        }.map
        {
            try String(
                contentsOf: directory.appendingPathComponent($0),
                encoding: .utf8
            )
        }.joined()
    }
}
