import Foundation

@MainActor
enum MacAdmissionMeasurement
{
    static func measure<Input, Output>(
        _ label: String,
        prepare: (Int) throws -> Input,
        action: (Input) throws -> Output,
        consume: (Input, Output) throws -> Void
    ) throws -> [Double]
    {
        let clock = ContinuousClock()
        var samples: [Double] = []
        for index in 0 ..< 35
        {
            let input = try prepare(index)
            let start = clock.now
            let output = try action(input)
            let duration = start.duration(to: clock.now).components
            try consume(input, output)
            if index >= 5
            {
                samples.append(
                    Double(duration.seconds) * 1_000
                        + Double(duration.attoseconds)
                            / 1_000_000_000_000_000
                )
            }
        }
        let sorted = samples.sorted()
        let median = (sorted[14] + sorted[15]) / 2
        print(
            "ADMISSION \(label) samplesMs=\(samples)"
                + " medianMs=\(median) p95Ms=\(sorted[28])"
                + " maxMs=\(sorted[29])"
        )
        return samples
    }
}
