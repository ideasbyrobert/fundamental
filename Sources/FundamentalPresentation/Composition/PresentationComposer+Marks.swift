import FundamentalRaster

extension PresentationComposer
{
    static func marks(
        _ values: [RasterMark],
        specification: PresentationRasterSpecificationIdentity
    ) -> [PresentationMark]?
    {
        var result: [PresentationMark] = []
        result.reserveCapacity(values.count)
        for value in values
        {
            guard let mark = mark(value, specification: specification)
            else
            {
                return nil
            }
            result.append(mark)
        }
        return result
    }

    static func mark(
        _ value: RasterMark,
        specification: PresentationRasterSpecificationIdentity
    ) -> PresentationMark?
    {
        switch value
        {
        case let .glyphs(batch):
            guard let batch = glyphBatch(
                batch,
                specification: specification
            )
            else
            {
                return nil
            }
            return .glyphs(batch)
        case let .fill(value):
            guard let converted = fill(
                value,
                specification: specification
            )
            else
            {
                return nil
            }
            return .fill(converted)
        }
    }
}
