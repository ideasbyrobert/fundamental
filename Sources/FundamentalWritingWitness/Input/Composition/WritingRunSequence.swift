import Foundation
import FundamentalDocument

struct WritingRunSequence: Equatable, Sendable
{
    let runs: [SemanticRun]
    let text: String

    init(_ runs: [SemanticRun])
    {
        self.runs = runs
        text = runs.map(\.text).joined()
    }

    func partition(_ range: NSRange) -> SemanticRunPartition?
    {
        let (end, overflow) = range.location.addingReportingOverflow(
            range.length
        )
        guard range.length >= 0, !overflow,
              let lower = DocumentUTF16Offset(range.location),
              let upper = DocumentUTF16Offset(end)
        else
        {
            return nil
        }
        return SemanticRunPartition(runs: runs, lowerBound: lower,
                                     upperBound: upper)
    }

    func replacing(
        _ range: NSRange, with inserted: [SemanticRun]
    ) -> WritingRunSequence?
    {
        guard let divided = partition(range)
        else
        {
            return nil
        }
        return Self(divided.prefix + inserted + divided.suffix)
    }
}
