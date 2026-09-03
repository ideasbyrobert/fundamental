package enum RasterMark: Equatable, Sendable
{
    case glyphs(RasterGlyphBatch)
    case fill(RasterFill)

    package var residentID: RasterResidentID
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
