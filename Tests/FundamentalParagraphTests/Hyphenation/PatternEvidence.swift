@testable import FundamentalParagraph
import Foundation

enum PatternEvidence
{
    static func write(
        _ name: String, group: String, record: [String: Any]
    ) throws
    {
        guard let path = ProcessInfo.processInfo.environment[
            "FUNDAMENTAL_PARAGRAPH_CAPTURE_DIR"
        ]
        else
        {
            return
        }
        let root = URL(fileURLWithPath: path)
        let folder = root.appendingPathComponent(group)
        try FileManager.default.createDirectory(
            at: folder, withIntermediateDirectories: true
        )
        let output = folder.appendingPathComponent(name + ".json")
        guard !FileManager.default.fileExists(atPath: output.path)
        else
        {
            throw PatternFailure.invalidResource
        }
        try JSONSerialization.data(
            withJSONObject: record, options: [.sortedKeys, .prettyPrinted]
        ).write(to: output, options: .atomic)
    }

    static func describe(_ result: PatternResult) -> [String: Any]
    {
        [
            "identity": result.identity,
            "wordUTF16": Array(result.word.utf16),
            "word": result.word,
            "boundaries": result.boundaries,
            "basis": result.basis.rawValue,
            "weights": result.match.weights,
            "edgeProbes": result.match.work.edgeProbes,
            "weightMerges": result.match.work.weightMerges,
            "terminalMatches": result.match.work.terminalMatches
        ]
    }
}
