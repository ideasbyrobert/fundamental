import FundamentalPresentation

struct MacRasterLineOrigin
{
    let source: PresentationPoint
    let marker: PresentationListMarker?

    init?(_ resident: PresentedResident)
    {
        guard let line = resident.content.textLine
        else
        {
            return nil
        }
        if let item = resident.content.listItem
        {
            let first = resident.residentID.fragmentOrdinal == 0
            guard (resident.content.listMarker != nil) == first
            else
            {
                return nil
            }
            if let marker = resident.content.listMarker
            {
                guard marker.source.residentID == resident.residentID,
                      marker.source.item == item
                else
                {
                    return nil
                }
            }
        }
        source = line.baseline
        marker = resident.content.listMarker
    }

    func resolve(_ batch: PresentationGlyphBatch) -> PresentationPoint?
    {
        switch batch.source
        {
        case .text:
            return source
        case let .listMarker(generated):
            guard let marker, marker.source == generated,
                  generated.residentID == batch.residentID,
                  batch.glyphs.allSatisfy({ $0.sourceSlices.isEmpty })
            else
            {
                return nil
            }
            return marker.baseline
        }
    }
}
