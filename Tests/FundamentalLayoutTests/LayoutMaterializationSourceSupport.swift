import Foundation
import Testing

extension LayoutFragmentMaterializationTests
{
    func productionSource(
        _ name: String
    ) throws -> String
    {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = root
            .appendingPathComponent("Sources")
            .appendingPathComponent("FundamentalLayout")
            .appendingPathComponent(name)
        return try String(contentsOf: url, encoding: .utf8)
    }

    func occurrences(
        of needle: String,
        in source: String
    ) -> Int
    {
        source.components(separatedBy: needle).count - 1
    }
}
