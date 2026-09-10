import FundamentalRaster

extension PresentationComposer
{
    static func residence(
        _ value: RasterResidence
    ) -> PresentationResidence
    {
        switch value
        {
        case .visible:
            .visible
        case .overscan(.preceding):
            .overscan(.preceding)
        case .overscan(.following):
            .overscan(.following)
        }
    }

    static func headingLevel(
        _ value: RasterHeadingLevel
    ) -> PresentationHeadingLevel?
    {
        PresentationHeadingLevel(rawValue: value.rawValue)
    }
}
