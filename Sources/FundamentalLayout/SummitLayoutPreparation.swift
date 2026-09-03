import FundamentalProjection

@MainActor
package final class SummitLayoutPreparation
{
    private let projection: ProjectionSnapshot
    private var cachedMeasure: Double
    private var cachedSnapshot: LayoutSnapshot
    private var generation: UInt64
    package private(set) var executionCount: Int

    package init?()
    {
        guard let corpus = SummitProjectionCorpus(),
              let request = Self.request(
                  measure: 720,
                  generation: 1
              ),
              let snapshot = try? NativeTextKit2Layout().layout(
                  corpus.snapshot,
                  request: request
              )
        else
        {
            return nil
        }
        projection = corpus.snapshot
        cachedMeasure = 720
        cachedSnapshot = snapshot
        generation = 1
        executionCount = 1
    }

    package func layout(
        readableMeasure: Double
    ) -> LayoutSnapshot?
    {
        guard readableMeasure.isFinite,
              readableMeasure > 0
        else
        {
            return nil
        }
        if readableMeasure == cachedMeasure
        {
            return cachedSnapshot
        }
        let (next, overflow) = generation.addingReportingOverflow(1)
        guard !overflow,
              let request = Self.request(
                  measure: readableMeasure,
                  generation: next
              ),
              let snapshot = try? NativeTextKit2Layout().layout(
                  projection,
                  request: request
              )
        else
        {
            return nil
        }
        cachedMeasure = readableMeasure
        cachedSnapshot = snapshot
        generation = next
        executionCount += 1
        return snapshot
    }

    private static func request(
        measure: Double,
        generation: UInt64
    ) -> LayoutRequest?
    {
        LayoutRequest(
            generation: generation,
            width: measure,
            blockSpacing: 18,
            rowSpacing: 6,
            columnSpacing: 10,
            cellPadding: 8
        )
    }
}
