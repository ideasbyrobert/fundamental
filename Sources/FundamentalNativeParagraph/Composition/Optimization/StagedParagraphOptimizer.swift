@MainActor
struct StagedParagraphOptimizer
{
    let cache: ParagraphEdgeCache
    let width: Double

    func optimize() throws -> StagedParagraphPath
    {
        let measurements = cache.nativeMeasurements
        let requests = cache.requests
        do
        {
            let path = try ParagraphOptimizer(
                cache: cache, width: width
            ).optimize(pass: .ordinary)
            return StagedParagraphPath(
                path: path, usedFallback: false,
                ordinaryMeasurements: cache.nativeMeasurements - measurements,
                ordinaryRequests: cache.requests - requests
            )
        }
        catch ParagraphFailure.noFeasibleLayout(_)
        {
            let measured = cache.nativeMeasurements - measurements
            let requested = cache.requests - requests
            let path = try ParagraphOptimizer(
                cache: cache, width: width
            ).optimize(pass: .complete)
            return StagedParagraphPath(
                path: path, usedFallback: true,
                ordinaryMeasurements: measured, ordinaryRequests: requested
            )
        }
    }
}
