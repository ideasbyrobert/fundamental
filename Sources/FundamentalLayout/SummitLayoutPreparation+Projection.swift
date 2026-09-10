import FundamentalProjection

extension SummitLayoutPreparation
{
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
}
