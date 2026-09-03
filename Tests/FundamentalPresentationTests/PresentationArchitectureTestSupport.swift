import Foundation
import Testing

extension PresentationArchitectureTests
{
    var root: URL
    {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    func productionSource() throws -> String
    {
        try source(at: root.appendingPathComponent(
            "Sources/FundamentalPresentation"
        ))
    }

    func valueSource() throws -> String
    {
        let base = root.appendingPathComponent(
            "Sources/FundamentalPresentation"
        )
        return try [
            "Adornments",
            "Appearance",
            "Document",
            "Geometry",
            "Lineage",
            "Marks",
            "Publication",
            "Residents",
            "Source",
            "Typography"
        ].map
        {
            try source(at: base.appendingPathComponent($0))
        }.joined()
    }

    func source(at directory: URL) throws -> String
    {
        let files = try #require(FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: nil
        ))
        return try files.compactMap
        {
            $0 as? URL
        }.filter
        {
            $0.pathExtension == "swift"
        }.sorted
        {
            $0.path < $1.path
        }.map
        {
            try String(contentsOf: $0, encoding: .utf8)
        }.joined()
    }
}
