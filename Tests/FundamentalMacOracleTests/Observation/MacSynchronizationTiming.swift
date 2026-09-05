import Foundation
import Testing

@MainActor
enum MacSynchronizationTiming
{
    static func measure(
        _ label: String,
        action: (Int) -> Bool
    ) throws
    {
        for index in 0 ..< 5
        {
            try #require(action(index))
        }
        let clock = ContinuousClock()
        var samples: [Double] = []
        for index in 0 ..< 30
        {
            let start = clock.now
            let succeeded = action(index + 5)
            let duration = start.duration(to: clock.now).components
            try #require(succeeded)
            samples.append(
                Double(duration.seconds) * 1_000
                    + Double(duration.attoseconds) / 1_000_000_000_000_000
            )
        }
        let sorted = samples.sorted()
        let median = (sorted[14] + sorted[15]) / 2
        print(
            "TIMING \(label) samplesMs=\(samples)"
                + " medianMs=\(median) p95Ms=\(sorted[28])"
                + " maxMs=\(sorted[29])"
        )
    }
}
