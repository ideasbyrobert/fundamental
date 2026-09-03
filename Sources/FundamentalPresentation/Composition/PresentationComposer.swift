import FundamentalRaster

package struct PresentationComposer
{
    package init()
    {
    }

    package func rasterLineage(
        of snapshot: RasterSnapshot
    ) -> PresentationRasterLineage?
    {
        Self.lineage(snapshot.lineage)
    }

    package func present(
        _ raster: RasterSnapshot,
        request: PresentationRequest
    ) -> PresentationSnapshot?
    {
        present(raster, request: request, previous: nil)
    }

    package func present(
        _ raster: RasterSnapshot,
        request: PresentationRequest,
        reusing previous: PresentationSnapshot
    ) -> PresentationSnapshot?
    {
        present(
            raster,
            request: request,
            previous: previous
        )
    }

    private func present(
        _ raster: RasterSnapshot,
        request: PresentationRequest,
        previous: PresentationSnapshot?
    ) -> PresentationSnapshot?
    {
        guard let rasterLineage = Self.lineage(raster.lineage),
              rasterLineage == request.expectedRasterLineage,
              request.specification.adornmentPalette.colorSpace
                == rasterLineage.specification.colorSpace,
              let document = Self.document(
                  raster,
                  rasterLineage: rasterLineage,
                  request: request,
                  previous: previous?.presentedDocument
              )
        else
        {
            return nil
        }
        switch request.intent
        {
        case .document:
            return .document(document)
        case let .caret(position):
            guard let adornment = Self.caret(
                at: position,
                document: document,
                specification: request.specification
            )
            else
            {
                return nil
            }
            return .caret(document, adornment)
        case let .selection(selection):
            guard let adornment = Self.selection(
                selection,
                document: document,
                specification: request.specification
            )
            else
            {
                return nil
            }
            return .selection(document, adornment)
        }
    }
}
