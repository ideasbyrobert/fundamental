import Darwin
import Foundation

struct WritingMeasurementReport
{
    let samples: [WritingMeasurementSample]
    let corpus: WritingMeasurementCorpus
    let location: WritingMeasurementLocation

    var p95: Double
    {
        let sorted = samples.map(\.totalMilliseconds).sorted()
        return sorted[Int(ceil(Double(sorted.count) * 0.95)) - 1]
    }

    func emit() throws
    {
        var usage = rusage()
        let hasUsage = getrusage(RUSAGE_SELF, &usage) == 0
        let sorted = samples.map(\.totalMilliseconds).sorted()
        let record: [String: Any] = [
            "stage": ProcessInfo.processInfo.environment[
                "FUNDAMENTAL_WRITING_MEASURE_LABEL"
            ] ?? "unspecified",
            "backend": "TextKit 2 native key through requested window drawing",
            "os": ProcessInfo.processInfo.operatingSystemVersionString,
            "paragraphs": corpus.paragraphCount,
            "corpus": corpus.semantic ? "mixed semantic" : "body paragraphs",
            "scoped": corpus.scoped,
            "utf16Units": corpus.utf16Count,
            "location": location.rawValue,
            "sampleCount": samples.count,
            "medianMilliseconds": sorted[sorted.count / 2],
            "p95Milliseconds": p95,
            "maximumMilliseconds": sorted.last ?? 0,
            "peakResidentBytes": hasUsage ? usage.ru_maxrss : -1,
            "samples": samples.map
            {
                ["keyMilliseconds": $0.keyMilliseconds,
                 "drawingMilliseconds": $0.drawingMilliseconds]
            }
        ]
        let data = try JSONSerialization.data(
            withJSONObject: record, options: [.sortedKeys]
        )
        print("WRITING_MEASUREMENT " + String(decoding: data, as: UTF8.self))
    }
}
