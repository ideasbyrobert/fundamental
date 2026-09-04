import FundamentalProjection

@MainActor
package final class SummitLayoutPreparation
{
    private let capacity: LayoutExtentIndexCapacity
    private var cachedMeasure: Double
    private var cachedProjection: LayoutIndexedProjection
    private var generation: UInt64
    package private(set) var executionCount: Int

    package convenience init?()
    {
        guard let corpus = SummitProjectionCorpus(),
              let capacity = Self.summitCapacity()
        else
        {
            return nil
        }
        self.init(
            projection: corpus.snapshot,
            initialMeasure: 720,
            capacity: capacity
        )
    }

    init?(
        projection: ProjectionSnapshot,
        initialMeasure: Double,
        capacity: LayoutExtentIndexCapacity
    )
    {
        guard let request = Self.request(
                  measure: initialMeasure,
                  generation: 1
              ),
              let indexed = try? NativeTextKit2Layout().indexedProjection(
                  projection,
                  request: request,
                  capacity: capacity
              )
        else
        {
            return nil
        }
        self.capacity = capacity
        cachedMeasure = initialMeasure
        cachedProjection = indexed
        generation = 1
        executionCount = 1
    }

    package func indexedProjection(
        readableMeasure: Double
    ) -> LayoutIndexedProjection?
    {
        guard readableMeasure.isFinite,
              readableMeasure > 0
        else
        {
            return nil
        }
        if readableMeasure == cachedMeasure
        {
            return cachedProjection
        }
        let (next, overflow) = generation.addingReportingOverflow(1)
        guard !overflow,
              let request = Self.request(
                  measure: readableMeasure,
                  generation: next
              ),
              let indexed = try? NativeTextKit2Layout().indexedProjection(
                  cachedProjection.projection,
                  request: request,
                  capacity: capacity
              )
        else
        {
            return nil
        }
        cachedMeasure = readableMeasure
        cachedProjection = indexed
        generation = next
        executionCount += 1
        return indexed
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

    private static func summitCapacity() -> LayoutExtentIndexCapacity?
    {
        LayoutExtentIndexCapacity(
            maximumBlockCount: 100_000,
            maximumExtentCount: 1_000_000,
            maximumResolvedFontCount: 4_096,
            maximumTableRowCount: 100_000,
            maximumTableCellCount: 100_000
        )
    }
}
