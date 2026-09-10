extension PresentationComposer
{
    static func validListMarks(
        _ marks: [PresentationMark], residentID: PresentationResidentID,
        content: PresentedResidentContent
    ) -> Bool
    {
        let marker = content.listMarker
        let generated: [PresentationGlyphBatch] = marks.compactMap
        {
            guard case let .glyphs(batch) = $0,
                  case .listMarker = batch.source
            else
            {
                return nil
            }
            return batch
        }
        guard let item = content.listItem
        else
        {
            return marker == nil && generated.isEmpty
        }
        guard (marker != nil) == (residentID.fragmentOrdinal == 0)
        else
        {
            return false
        }
        if let marker
        {
            guard marker.source.residentID == residentID,
                  marker.source.item == item, !generated.isEmpty
            else
            {
                return false
            }
            for batch in generated
            {
                guard batch.source == .listMarker(marker.source),
                      batch.glyphs.allSatisfy({ $0.sourceSlices.isEmpty })
                else
                {
                    return false
                }
            }
        }
        else if !generated.isEmpty
        {
            return false
        }
        return marks.allSatisfy
        {
            guard case let .fill(fill) = $0 else { return true }
            return (fill.role == .underline || fill.role == .strikethrough)
                && !fill.sourceSlices.isEmpty
        }
    }
}
