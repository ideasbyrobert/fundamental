import Foundation
import FundamentalNativeParagraph
import Testing

@MainActor
enum LayoutProseCapture
{
    static func write(_ value: ParagraphComposition, name: String) throws
    {
        guard let path = ProcessInfo.processInfo.environment[
            "FUNDAMENTAL_LAYOUT_SOURCE_CAPTURE_DIR"
        ]
        else
        {
            return
        }
        let source = value.collection.source
        let runs = try JSONSerialization.jsonObject(
            with: JSONEncoder().encode(source.paragraph.runs)
        )
        let record: [String: Any] = [
            "width": value.width,
            "runs": runs,
            "units": source.source.utf16,
            "spans": source.spans.map
            {
                [
                    "index": $0.index,
                    "range": range($0.range),
                    "language": $0.language.value
                ] as [String: Any]
            },
            "lines": try value.segments.flatMap(\.lines).map(line)
        ]
        let data = try JSONSerialization.data(
            withJSONObject: record, options: [.prettyPrinted, .sortedKeys]
        )
        let directory = URL(fileURLWithPath: path, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directory, withIntermediateDirectories: true
        )
        try data.write(
            to: directory.appendingPathComponent(name + ".json"),
            options: .withoutOverwriting
        )
    }

    static func range(_ value: Range<Int>) -> [Int]
    {
        [value.lowerBound, value.upperBound]
    }
}
