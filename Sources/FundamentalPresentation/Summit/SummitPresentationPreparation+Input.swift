import FundamentalRaster

extension SummitPresentationPreparation
{
    static func rasterPreparation(
        projection: PresentationDocumentProjection?,
        initialMeasure: Double
    ) -> SummitRasterPreparation?
    {
        if let projection
        {
            return SummitRasterPreparation(
                projection: projection, initialMeasure: initialMeasure
            )
        }
        return SummitRasterPreparation()
    }
}
