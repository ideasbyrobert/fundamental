import Foundation

struct WritingRecoverySchedule
{
    private(set) var firstChange: ContinuousClock.Instant?
    private(set) var deadline: ContinuousClock.Instant?

    mutating func changed(at now: ContinuousClock.Instant)
    {
        let first = firstChange ?? now
        firstChange = first
        deadline = min(now.advanced(by: .seconds(2)),
                       first.advanced(by: .seconds(10)))
    }

    mutating func reset()
    {
        firstChange = nil
        deadline = nil
    }
}
