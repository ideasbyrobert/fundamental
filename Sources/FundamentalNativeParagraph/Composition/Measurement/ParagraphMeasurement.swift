import FundamentalNativeWrapping

@MainActor
enum ParagraphMeasurement
{
    static func measure(
        _ display: HyphenatedDisplay, attributes: ParagraphAttributes
    ) throws -> NativeWrappingLine
    {
        try NativeParagraphShaping.measure(
            attributes.attributed(display), inlineOffset: 0
        )
    }
}
