struct CodeConversionLines: Equatable, Sendable
{
    let ranges: [Range<Int>]
    let runs: [[SemanticRun]]

    init?(runs: [SemanticRun])
    {
        let units = Array(runs.lazy.map(\.text).joined().utf16)
        let ranges = Self.ranges(in: units)
        guard let partition = Self.partition(runs, ranges: ranges)
        else
        {
            return nil
        }
        self.ranges = ranges
        self.runs = partition
    }
}
