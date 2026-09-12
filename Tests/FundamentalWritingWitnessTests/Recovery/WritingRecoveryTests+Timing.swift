import Foundation
import Testing

@testable import FundamentalWritingWitness

extension WritingRecoveryTests
{
    @Test("checkpoint waits two idle seconds and never beyond ten seconds")
    func deadlines() throws
    {
        let start = ContinuousClock.now
        var schedule = WritingRecoverySchedule()
        schedule.changed(at: start)
        #expect(schedule.deadline == start.advanced(by: .seconds(2)))
        schedule.changed(at: start.advanced(by: .seconds(1)))
        #expect(schedule.deadline == start.advanced(by: .seconds(3)))
        for second in 2...20
        {
            schedule.changed(at: start.advanced(by: .seconds(second)))
            let deadline = try #require(schedule.deadline)
            #expect(deadline <= start.advanced(by: .seconds(10)))
        }
        schedule.reset()
        #expect(schedule.deadline == nil)
        let next = start.advanced(by: .seconds(30))
        schedule.changed(at: next)
        #expect(schedule.deadline == next.advanced(by: .seconds(2)))
    }
}
