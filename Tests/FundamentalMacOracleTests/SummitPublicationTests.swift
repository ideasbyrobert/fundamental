import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

@Suite("The macOS summit publication fence")
@MainActor
struct SummitPublicationTests
{
    @Test("an older completed attempt cannot replace a newer generation")
    func staleAttemptCannotPublish() throws
    {
        let (preparation, surface) = try MacOracleTestPreparation.make()
        let executor = MacRasterExecutor()
        let olderLease = try #require(preparation.reserveAttempt())
        let newerLease = try #require(preparation.reserveAttempt())
        let older = try #require(preparation.prepare(
            surface: surface,
            intent: .document,
            lease: olderLease
        ))
        let newer = try #require(preparation.prepare(
            surface: surface,
            intent: .document,
            lease: newerLease
        ))
        #expect(executor.admits(older.snapshot))
        #expect(executor.admits(newer.snapshot))
        #expect(preparation.publish(newer))
        let published = preparation.currentSnapshot
        #expect(!preparation.publish(older))
        #expect(preparation.currentSnapshot == published)
        #expect(published.lineage.generation == newerLease.generation)
    }
}
