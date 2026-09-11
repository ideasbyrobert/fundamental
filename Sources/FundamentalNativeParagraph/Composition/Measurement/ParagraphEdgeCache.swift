@MainActor
final class ParagraphEdgeCache
{
    let collection: ParagraphHyphens
    let candidates: ParagraphBreakSet
    let attributes: ParagraphAttributes
    private(set) var nativeMeasurements = 0
    private(set) var requests = 0
    private(set) var entries: [ParagraphEdgeKey: ParagraphEdgeMeasurement] = [:]

    init(
        collection: ParagraphHyphens, candidates: ParagraphBreakSet,
        attributes: ParagraphAttributes
    )
    {
        self.collection = collection
        self.candidates = candidates
        self.attributes = attributes
    }

    func measure(from start: Int, to end: Int) throws
        -> ParagraphEdgeMeasurement
    {
        requests += 1
        let key = ParagraphEdgeKey(
            start: candidates.breaks[start].position, end: end
        )
        if let cached = entries[key]
        {
            return cached
        }
        let a = candidates.breaks[start]
        let b = candidates.breaks[end]
        let emptyTerminal = start == 0 && b.terminal
            && a.position == b.position
        guard a.position <= b.visibleEnd,
              b.position > a.position || emptyTerminal
        else
        {
            entries[key] = .unavailable
            return .unavailable
        }
        let display = try HyphenatedDisplay(
            collection, range: a.position..<b.visibleEnd,
            end: b.kind.displayEnd
        )
        let native = try ParagraphMeasurement.measure(
            display, attributes: attributes
        )
        nativeMeasurements += 1
        let result = ParagraphEdgeMeasurement.measured(
            try ParagraphLineMetrics(native, units: display.units)
        )
        entries[key] = result
        return result
    }
}
