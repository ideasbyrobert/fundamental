import FundamentalPresentation

extension MacReaderModel
{
    package func nearestPosition(
        to point: PresentationPoint
    ) -> PresentationTextPosition?
    {
        let candidates = snapshot.presentedDocument.residents.all.enumerated()
            .flatMap
        {
            residentIndex, resident
                -> [(
                    Int,
                    Int,
                    PresentedResident,
                    PresentedCaretSite,
                    PresentationRectangle
                )] in
            guard let line = Self.textLine(resident.content)
            else
            {
                return []
            }
            return line.caretSites.enumerated().map
            {
                siteIndex, site in
                (
                    residentIndex,
                    siteIndex,
                    resident,
                    site,
                    line.lineBounds
                )
            }
        }
        guard let candidate = candidates.min(by:
        {
            let leftY = Self.verticalDistance(point, bounds: $0.4)
            let rightY = Self.verticalDistance(point, bounds: $1.4)
            if leftY != rightY
            {
                return leftY < rightY
            }
            let leftX = abs($0.3.position.x - point.x)
            let rightX = abs($1.3.position.x - point.x)
            if leftX != rightX
            {
                return leftX < rightX
            }
            if $0.0 != $1.0
            {
                return $0.0 < $1.0
            }
            return $0.1 < $1.1
        })
        else
        {
            return nil
        }
        return PresentationTextPosition(
            residentID: candidate.2.residentID,
            sourcePoint: candidate.3.sourcePoint
        )
    }
}
