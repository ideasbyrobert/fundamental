import FundamentalProjection

@MainActor
package final class SummitLayoutPreparation
{
    let capacity: LayoutExtentIndexCapacity
    var cachedMeasure: Double
    var cachedProjection: LayoutIndexedProjection
    var generation: UInt64
    package internal(set) var executionCount: Int

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

    package convenience init?(
        projection: LayoutDocumentProjection,
        initialMeasure: Double
    )
    {
        guard let capacity = Self.summitCapacity()
        else
        {
            return nil
        }
        self.init(
            projection: projection,
            initialMeasure: initialMeasure,
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
}
