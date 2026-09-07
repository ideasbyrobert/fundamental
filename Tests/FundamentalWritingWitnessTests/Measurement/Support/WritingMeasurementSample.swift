struct WritingMeasurementSample
{
    let keyMilliseconds: Double
    let drawingMilliseconds: Double

    init(key: Duration, drawing: Duration)
    {
        keyMilliseconds = Self.milliseconds(key)
        drawingMilliseconds = Self.milliseconds(drawing)
    }

    var totalMilliseconds: Double
    {
        keyMilliseconds + drawingMilliseconds
    }

    static func milliseconds(_ duration: Duration) -> Double
    {
        let value = duration.components
        return Double(value.seconds) * 1_000 +
            Double(value.attoseconds) / 1_000_000_000_000_000
    }
}
