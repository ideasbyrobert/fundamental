import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationPublisherTests
{
    @MainActor
    @Test("publication initialization refuses a future current snapshot")
    func initialGenerationIsBounded() throws
    {
        let raster = try makeRaster()
        let current = try PresentationFixture.snapshot(
            raster,
            generation: 20
        )
        #expect(PresentationPublisher(
            current: current,
            latestAttempt: PresentationAttemptLease(generation: 19)
        ) == nil)
    }

    @MainActor
    @Test("lease exhaustion leaves the maximum lease unchanged")
    func leaseExhaustion() throws
    {
        let raster = try makeRaster()
        let current = try PresentationFixture.snapshot(raster)
        let maximum = PresentationAttemptLease(generation: UInt64.max)
        let publisher = try #require(PresentationPublisher(
            current: current,
            latestAttempt: maximum
        ))
        #expect(publisher.reserveAttempt() == nil)
        #expect(publisher.latestAttempt == maximum)
        #expect(publisher.currentSnapshot == current)
    }

    @MainActor
    func makeRaster() throws -> RasterSnapshot
    {
        try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([
                    .paragraph(SemanticParagraph(runs: [
                        PresentationFixture.run("Published")
                    ]))
                ])
            )
        )
    }
}
