import FundamentalViewport

@MainActor
package final class SummitRasterPreparation
{
    let viewportPreparation: SummitViewportPreparation

    package init?()
    {
        guard let preparation = SummitViewportPreparation()
        else
        {
            return nil
        }
        viewportPreparation = preparation
    }

    package init?(
        projection: RasterDocumentProjection,
        initialMeasure: Double
    )
    {
        guard let preparation = SummitViewportPreparation(
            projection: projection, initialMeasure: initialMeasure
        )
        else
        {
            return nil
        }
        viewportPreparation = preparation
    }

    package var layoutExecutionCount: Int
    {
        viewportPreparation.layoutExecutionCount
    }
}
