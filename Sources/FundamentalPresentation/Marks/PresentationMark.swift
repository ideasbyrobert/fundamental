package enum PresentationMark: Equatable, Sendable
{
    case glyphs(PresentationGlyphBatch)
    case fill(PresentationFill)

    package var residentID: PresentationResidentID
    {
        switch self
        {
        case let .glyphs(batch):
            batch.residentID
        case let .fill(fill):
            fill.residentID
        }
    }
}
