import Testing

@testable import FundamentalLayout
@testable import FundamentalViewport

@Suite("Bounded viewport work")
struct ViewportBoundedWorkTests
{
    @MainActor
    @Test("resident and examined work ignore total document length")
    func lengthIndependentWork() throws
    {
        let short = try ViewportFixture.layout(repetitions: 40)
        let long = try ViewportFixture.layout(repetitions: 800)
        #expect(long.fragments.count > short.fragments.count * 10)
        let shortBounds = try ViewportFixture.bounds(
            of: short.fragments[10]
        )
        let longBounds = try ViewportFixture.bounds(
            of: long.fragments[10]
        )
        let shortRequest = try ViewportFixture.request(
            layout: short,
            bounds: shortBounds,
            preceding: 40,
            following: 40,
            limit: 5
        )
        let longRequest = try ViewportFixture.request(
            layout: long,
            bounds: longBounds,
            preceding: 40,
            following: 40,
            limit: 5
        )
        let shortAdmission = try #require(
            ViewportSnapshot.admissionDiagnostics(
            short,
            request: shortRequest
        ))
        let longAdmission = try #require(
            ViewportSnapshot.admissionDiagnostics(
            long,
            request: longRequest
        ))
        let shortResidents = shortAdmission.snapshot.residents.all
        let longResidents = longAdmission.snapshot.residents.all
        #expect(shortResidents.count == 5)
        #expect(longResidents.count == 5)
        #expect(longResidents.map(\.residence)
            == shortResidents.map(\.residence))
        #expect(longResidents.map(\.fragment.anchor)
            == shortResidents.map(\.fragment.anchor))
        #expect(longResidents.map(\.fragment.frame)
            == shortResidents.map(\.fragment.frame))
        #expect(shortAdmission.query.precedingFragmentsExamined > 0)
        #expect(shortAdmission.query.followingFragmentsExamined > 0)
        #expect(longAdmission.query == shortAdmission.query)
        #expect(longAdmission.query.totalFragmentsExamined <= 18)
    }

    @MainActor
    @Test("zero overscan performs no overscan query")
    func zeroOverscan() throws
    {
        let layout = try ViewportFixture.layout(repetitions: 800)
        let bounds = try ViewportFixture.bounds(
            of: layout.fragments[10]
        )
        let request = try ViewportFixture.request(
            layout: layout,
            bounds: bounds,
            limit: 3
        )
        let admission = try #require(
            ViewportSnapshot.admissionDiagnostics(
                layout,
                request: request
            )
        )
        #expect(admission.query.visibleFragmentsExamined > 0)
        #expect(admission.query.precedingFragmentsExamined == 0)
        #expect(admission.query.followingFragmentsExamined == 0)
    }
}
