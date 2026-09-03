import FundamentalRaster

extension PresentationComposer
{
    static func document(
        _ raster: RasterSnapshot,
        rasterLineage: PresentationRasterLineage,
        request: PresentationRequest,
        previous: PresentedDocument?
    ) -> PresentedDocument?
    {
        guard let documentSize = size(raster.documentSize),
              let plane = documentPlane(
                  documentSize: documentSize,
                  rasterLineage: rasterLineage
              ),
              let marks = marks(
                  raster.marks,
                  specification: rasterLineage.specification
              ),
              let anchorID = residentID(
                  raster.sourceAnchor.residentID
              ),
              raster.sourceAnchor.relativeX.isFinite,
              raster.sourceAnchor.relativeY.isFinite
        else
        {
            return nil
        }
        let canReuse = reusableContext(
            previous,
            rasterLineage: rasterLineage,
            plane: plane
        )
        let reusable = canReuse
            ? reusableResidents(previous)
            : [:]
        var marksByResident: [
            PresentationResidentID: [PresentationMark]
        ] = [:]
        for mark in marks
        {
            marksByResident[mark.residentID, default: []].append(mark)
        }
        var residents: [PresentedResident] = []
        residents.reserveCapacity(
            1 + raster.interactionMap.remainingRegions.count
        )
        let regionCount = 1 + raster.interactionMap.remainingRegions.count
        for index in 0 ..< regionCount
        {
            let region = index == 0
                ? raster.interactionMap.firstRegion
                : raster.interactionMap.remainingRegions[index - 1]
            guard let identifier = residentID(region.residentID),
                  !residents.contains(where:
                  {
                      $0.residentID == identifier
                  }),
                  let resident = resident(
                      region,
                      marks: marksByResident[identifier] ?? [],
                      reusable: reusable
                  )
            else
            {
                return nil
            }
            residents.append(resident)
        }
        let marksResolve = marks.allSatisfy
        {
            mark in
            residents.filter
            {
                $0.residentID == mark.residentID
            }.count == 1
        }
        guard let first = residents.first,
              marksResolve,
              let anchor = residents.first(where:
              {
                  $0.residentID == anchorID
              }),
              anchor.frame.minX
                - rasterLineage.viewport.specification
                    .visibleBounds.minX
                == raster.sourceAnchor.relativeX,
              anchor.frame.minY
                - rasterLineage.viewport.specification
                    .visibleBounds.minY
                == raster.sourceAnchor.relativeY
        else
        {
            return nil
        }
        let sourceAnchor = PresentationSourceAnchor(
            residentID: anchorID,
            relativeX: raster.sourceAnchor.relativeX,
            relativeY: raster.sourceAnchor.relativeY
        )
        let collection = PresentedResidentCollection(
            first: first,
            remaining: Array(residents.dropFirst())
        )
        let candidate = PresentedDocumentStorage(
            plane: plane,
            sourceAnchor: sourceAnchor,
            residents: collection,
            marks: marks
        )
        let storage: PresentedDocumentStorage
        if canReuse,
           let previous,
           previous.storage == candidate
        {
            storage = previous.storage
        }
        else
        {
            storage = candidate
        }
        return PresentedDocument(
            lineage: PresentationLineage(
                raster: rasterLineage,
                generation: request.generation,
                specification: request.specification
            ),
            storage: storage
        )
    }

    static func documentPlane(
        documentSize: PresentationSize,
        rasterLineage: PresentationRasterLineage
    ) -> PresentationDocumentPlane?
    {
        let specification = rasterLineage.specification
        guard specification.logicalBounds.minX >= 0,
              specification.logicalBounds.maxX <= documentSize.width,
              specification.logicalBounds.minY >= 0,
              specification.logicalBounds.maxY <= documentSize.height
        else
        {
            return nil
        }
        return PresentationDocumentPlane(
            documentSize: documentSize,
            logicalBounds: specification.logicalBounds,
            pixelBounds: specification.pixelBounds,
            backingScale: specification.backingScale,
            appearance: specification.appearance,
            colorSpace: specification.colorSpace,
            palette: specification.palette
        )
    }

    static func reusableContext(
        _ previous: PresentedDocument?,
        rasterLineage: PresentationRasterLineage,
        plane: PresentationDocumentPlane
    ) -> Bool
    {
        guard let previous
        else
        {
            return false
        }
        return previous.lineage.raster.viewport.layout.document.documentID
                == rasterLineage.viewport.layout.document.documentID
            && previous.lineage.raster.viewport.layout.document.revision
                == rasterLineage.viewport.layout.document.revision
            && previous.plane.backingScale == plane.backingScale
            && previous.plane.appearance == plane.appearance
            && previous.plane.colorSpace == plane.colorSpace
            && previous.plane.palette == plane.palette
    }

    static func reusableResidents(
        _ previous: PresentedDocument?
    ) -> [PresentationResidentID: PresentedResidentStorage]
    {
        guard let previous
        else
        {
            return [:]
        }
        return Dictionary(
            uniqueKeysWithValues: previous.residents.all.map
            {
                ($0.residentID, $0.storage)
            }
        )
    }
}
