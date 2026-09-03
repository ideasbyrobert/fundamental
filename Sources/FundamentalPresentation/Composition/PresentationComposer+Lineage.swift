import FundamentalRaster

extension PresentationComposer
{
    static func lineage(
        _ value: RasterLineage
    ) -> PresentationRasterLineage?
    {
        let viewport = value.viewport
        let layout = viewport.layout
        let projection = layout.projection
        let layoutSpecification = layout.specification
        let parameters = layoutSpecification.parameters
        var fonts: [PresentationFontIdentity] = []
        fonts.reserveCapacity(layoutSpecification.resolvedFonts.count)
        for value in layoutSpecification.resolvedFonts
        {
            guard nonblank(value.postScriptName),
                  nonblank(value.uniqueName),
                  nonblank(value.versionName),
                  value.pointSize.isFinite,
                  value.pointSize > 0,
                  let matrix = transform(
                      a: value.matrix.a,
                      b: value.matrix.b,
                      c: value.matrix.c,
                      d: value.matrix.d,
                      tx: value.matrix.tx,
                      ty: value.matrix.ty
                  ),
                  let variations = fontVariations(
                      value.variations.map
                      {
                          ($0.axis, $0.value)
                      }
                  ),
                  let metrics = fontMetrics(
                      ascent: value.metrics.ascent,
                      descent: value.metrics.descent,
                      leading: value.metrics.leading,
                      capHeight: value.metrics.capHeight,
                      xHeight: value.metrics.xHeight,
                      underlinePosition:
                        value.metrics.underlinePosition,
                      underlineThickness:
                        value.metrics.underlineThickness,
                      unitsPerEm: value.metrics.unitsPerEm
                  )
            else
            {
                return nil
            }
            fonts.append(PresentationFontIdentity(
                postScriptName: value.postScriptName,
                uniqueName: value.uniqueName,
                versionName: value.versionName,
                pointSize: value.pointSize,
                matrix: matrix,
                variations: variations,
                metrics: metrics
            ))
        }
        let parameterValues = [
            parameters.width,
            parameters.blockSpacing,
            parameters.rowSpacing,
            parameters.columnSpacing,
            parameters.cellPadding
        ]
        guard parameterValues.allSatisfy(\.isFinite),
              parameters.width > 0,
              parameterValues.dropFirst().allSatisfy(
              {
                  $0 >= 0
              }),
              let visibleBounds = rectangle(
                  x: viewport.specification.visibleBounds.minX,
                  y: viewport.specification.visibleBounds.minY,
                  width: viewport.specification
                    .visibleBounds.size.width,
                  height: viewport.specification
                    .visibleBounds.size.height
              ),
              viewport.specification.precedingOverscanExtent.isFinite,
              viewport.specification.followingOverscanExtent.isFinite,
              viewport.specification.precedingOverscanExtent >= 0,
              viewport.specification.followingOverscanExtent >= 0,
              viewport.specification.maximumResidentCount > 0,
              let rasterSpecification = rasterSpecification(
                  value.specification
              )
        else
        {
            return nil
        }
        let document = PresentationDocumentLineage(
            documentID: projection.documentID,
            revision: projection.revision,
            projectionGeneration: projection.generation
        )
        let layoutIdentity = PresentationLayoutSpecificationIdentity(
            version: layoutSpecification.version,
            parameters: PresentationLayoutParameters(
                width: parameters.width,
                blockSpacing: parameters.blockSpacing,
                rowSpacing: parameters.rowSpacing,
                columnSpacing: parameters.columnSpacing,
                cellPadding: parameters.cellPadding
            ),
            resolvedFonts: fonts
        )
        let layoutLineage = PresentationLayoutLineage(
            document: document,
            generation: layout.generation,
            specification: layoutIdentity
        )
        let viewportIdentity = PresentationViewportSpecificationIdentity(
            visibleBounds: visibleBounds,
            precedingOverscanExtent:
                viewport.specification.precedingOverscanExtent,
            followingOverscanExtent:
                viewport.specification.followingOverscanExtent,
            maximumResidentCount:
                viewport.specification.maximumResidentCount
        )
        return PresentationRasterLineage(
            viewport: PresentationViewportLineage(
                layout: layoutLineage,
                generation: viewport.generation,
                specification: viewportIdentity
            ),
            generation: value.generation,
            specification: rasterSpecification
        )
    }

    static func rasterSpecification(
        _ value: RasterSpecificationIdentity
    ) -> PresentationRasterSpecificationIdentity?
    {
        guard value.backingScale.isFinite,
              value.backingScale > 0,
              let bounds = rectangle(value.logicalBounds),
              let pixels = pixelBounds(
                  value.pixelBounds,
                  logicalBounds: bounds,
                  backingScale: value.backingScale
              ),
              let space = colorSpace(value.colorSpace),
              let palette = palette(value.palette),
              palette.colorSpace == space,
              let capacities = capacities(value.capacities)
        else
        {
            return nil
        }
        return PresentationRasterSpecificationIdentity(
            logicalBounds: bounds,
            pixelBounds: pixels,
            backingScale: value.backingScale,
            appearance: appearance(value.appearance),
            colorSpace: space,
            palette: palette,
            capacities: capacities
        )
    }

    static func capacities(
        _ value: RasterCapacities
    ) -> PresentationRasterCapacities?
    {
        let values = [
            value.marks,
            value.glyphs,
            value.fills,
            value.sourceSlices,
            value.caretSites,
            value.interactionRegions,
            value.fontVariations,
            value.residentUTF16Units,
            value.pixelArea
        ]
        guard values.allSatisfy(
        {
            $0 > 0
        })
        else
        {
            return nil
        }
        return PresentationRasterCapacities(
            marks: value.marks,
            glyphs: value.glyphs,
            fills: value.fills,
            sourceSlices: value.sourceSlices,
            caretSites: value.caretSites,
            interactionRegions: value.interactionRegions,
            fontVariations: value.fontVariations,
            residentUTF16Units: value.residentUTF16Units,
            pixelArea: value.pixelArea
        )
    }
}
