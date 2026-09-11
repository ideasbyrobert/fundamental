extension HyphenatedShapedLine
{
    init(
        display: HyphenatedDisplay, attributes: ParagraphAttributes
    ) throws
    {
        let measured = try ParagraphMeasurement.measure(
            display, attributes: attributes
        )
        self.display = display
        measurement = measured
        runs = try NativeParagraphShaping.runs(
            measured, displayLength: display.units.count,
            sources: display.sources(in:)
        )
    }
}
