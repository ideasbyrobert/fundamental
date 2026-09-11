@testable import FundamentalParagraph
import FundamentalNativeParagraph
import Foundation

enum RangeEvidence
{
    static func record(_ name: String, values: [String: Int]) throws
    {
        guard let path = ProcessInfo.processInfo.environment[
            "FUNDAMENTAL_PARAGRAPH_CAPTURE_DIR"
        ]
        else
        {
            return
        }
        let root = URL(fileURLWithPath: path)
            .appendingPathComponent("index-work")
        try FileManager.default.createDirectory(
            at: root, withIntermediateDirectories: true
        )
        let output = root.appendingPathComponent(name + ".json")
        guard !FileManager.default.fileExists(atPath: output.path)
        else
        {
            throw WordFixtureFailure.invalidValue
        }
        try JSONSerialization.data(
            withJSONObject: values, options: [.sortedKeys, .prettyPrinted]
        ).write(to: output, options: .atomic)
    }
}
