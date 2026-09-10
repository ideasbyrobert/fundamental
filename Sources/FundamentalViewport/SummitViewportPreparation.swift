import FundamentalLayout

@MainActor
package final class SummitViewportPreparation
{
    let layoutPreparation: SummitLayoutPreparation

    package init?()
    {
        guard let preparation = SummitLayoutPreparation()
        else
        {
            return nil
        }
        layoutPreparation = preparation
    }

    init(layoutPreparation: SummitLayoutPreparation)
    {
        self.layoutPreparation = layoutPreparation
    }

    package init?(
        projection: ViewportDocumentProjection,
        initialMeasure: Double
    )
    {
        guard let preparation = SummitLayoutPreparation(
            projection: projection, initialMeasure: initialMeasure
        )
        else
        {
            return nil
        }
        layoutPreparation = preparation
    }

    package var layoutExecutionCount: Int
    {
        layoutPreparation.executionCount
    }
}
