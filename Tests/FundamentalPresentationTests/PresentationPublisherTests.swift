import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

@Suite("Presentation publication")
struct PresentationPublisherTests
{
    @MainActor
    @Test("only the exact newest lease may publish")
    func newestLeaseWins() throws
    {
        let raster = try makeRaster()
        let initial = try PresentationFixture.snapshot(
            raster,
            generation: 19
        )
        let publisher = try #require(PresentationPublisher(
            current: initial,
            latestAttempt: PresentationAttemptLease(generation: 19)
        ))
        let older = try #require(publisher.reserveAttempt())
        let newest = try #require(publisher.reserveAttempt())
        #expect(older.generation == 20)
        #expect(newest.generation == 21)
        let oldSnapshot = try PresentationFixture.snapshot(
            raster,
            generation: older.generation
        )
        let newSnapshot = try PresentationFixture.snapshot(
            raster,
            generation: newest.generation
        )
        #expect(!publisher.publish(oldSnapshot, lease: older))
        #expect(publisher.currentSnapshot == initial)
        #expect(publisher.publish(newSnapshot, lease: newest))
        #expect(publisher.currentSnapshot == newSnapshot)
        #expect(!publisher.publish(oldSnapshot, lease: older))
        #expect(publisher.currentSnapshot == newSnapshot)
    }

    @MainActor
    @Test("a refused newest attempt permanently fences older work")
    func refusalKeepsFence() throws
    {
        let raster = try makeRaster()
        let initial = try PresentationFixture.snapshot(raster)
        let publisher = try #require(PresentationPublisher(
            current: initial,
            latestAttempt: PresentationAttemptLease(generation: 19)
        ))
        let older = try #require(publisher.reserveAttempt())
        let newest = try #require(publisher.reserveAttempt())
        let oldSnapshot = try PresentationFixture.snapshot(
            raster,
            generation: older.generation
        )
        let wrongGeneration = try PresentationFixture.snapshot(
            raster,
            generation: newest.generation + 1
        )
        #expect(!publisher.publish(wrongGeneration, lease: newest))
        #expect(!publisher.publish(oldSnapshot, lease: older))
        #expect(publisher.latestAttempt == newest)
        #expect(publisher.currentSnapshot == initial)
    }
}
