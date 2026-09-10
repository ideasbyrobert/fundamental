import Testing

@testable import FundamentalPresentation

extension MacRasterOriginFixture
{
    static func specimen() throws -> (
        snapshot: PresentationSnapshot, batch: PresentationGlyphBatch,
        resident: PresentedResident, line: PresentedTextLine
    )
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let batch = try #require(
            MacRasterSnapshotFixture.firstTextBatch(in: snapshot)
        )
        let resident = try #require(
            snapshot.presentedDocument.residents.all.first
            {
                $0.residentID == batch.residentID
            }
        )
        return (snapshot, batch, resident,
                try line(for: batch, in: snapshot))
    }
}
