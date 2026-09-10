import FundamentalLayout

extension SummitViewportPreparation
{
    package func viewport(
        generation: UInt64,
        readableMeasure: Double,
        visibleOriginY: Double,
        visibleHeight: Double,
        overscanExtent: Double,
        maximumResidentCount: Int
    ) -> ViewportSnapshot?
    {
        viewportDiagnostics(
            generation: generation,
            readableMeasure: readableMeasure,
            visibleOriginY: visibleOriginY,
            visibleHeight: visibleHeight,
            overscanExtent: overscanExtent,
            maximumResidentCount: maximumResidentCount
        )?.snapshot
    }
}
