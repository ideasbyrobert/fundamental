import FundamentalPresentation

extension MacReaderModel
{
    package var snapshot: PresentationSnapshot
    {
        currentPublication.snapshot
    }

    var rasterExecution: MacAdmittedRasterExecution
    {
        currentPublication.execution
    }

    package var layoutExecutionCount: Int
    {
        preparation.layoutExecutionCount
    }

    package var documentWidth: Double
    {
        snapshot.presentedDocument.plane.documentSize.width
    }

    package var documentHeight: Double
    {
        snapshot.presentedDocument.plane.documentSize.height
    }

    package var readableMeasure: Double
    {
        currentSurface.readableMeasure
    }

    package var visibleOriginY: Double
    {
        snapshot.lineage.raster.viewport.specification
            .visibleBounds.minY
    }
}
