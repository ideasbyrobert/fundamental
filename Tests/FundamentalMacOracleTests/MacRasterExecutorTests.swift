import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

@Suite("The macOS summit raster executor")
@MainActor
struct MacRasterExecutorTests
{
    @Test("isolated shaped color emoji reach native pixels")
    func colorEmojiReachPixels() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let empty = MacRasterSnapshotFixture.replacingMarks(
            in: snapshot,
            with: []
        )
        let reference = try #require(MacBitmapSurface(empty))
        #expect(reference.draw(empty))
        let batches = snapshot.presentedDocument.marks.compactMap
        {
            mark -> PresentationGlyphBatch? in
            guard case let .glyphs(batch) = mark,
                  batch.font.postScriptName == ".AppleColorEmojiUI"
            else
            {
                return nil
            }
            return batch
        }
        #expect(!batches.isEmpty)
        for batch in batches
        {
            let isolated = MacRasterSnapshotFixture.replacingMarks(
                in: snapshot,
                with: [.glyphs(batch)]
            )
            let surface = try #require(MacBitmapSurface(isolated))
            #expect(surface.draw(isolated))
            #expect(!surface.changedPixels(
                from: reference,
                in: batch.pixelBounds
            ).isEmpty, "\(batch.sourceSlices.map(\.text).joined())")
        }
    }

    @Test("the summit admits only its observed identity text matrix")
    func textMatrixAdmissionIsExact() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let matrices = snapshot.presentedDocument.marks.compactMap
        {
            mark -> PresentationAffineTransform? in
            guard case let .glyphs(batch) = mark
            else
            {
                return nil
            }
            return batch.textMatrix
        }
        #expect(!matrices.isEmpty)
        #expect(matrices.allSatisfy(MacRasterExecutor.admitsTextMatrix))
        let altered = try #require(PresentationAffineTransform(
            a: 1,
            b: 0,
            c: 0,
            d: 1,
            tx: 1,
            ty: 0
        ))
        #expect(!MacRasterExecutor.admitsTextMatrix(altered))
        let poisoned = try #require(
            MacRasterSnapshotFixture.replacingFirstMatrix(
                in: snapshot,
                with: altered
            )
        )
        #expect(!MacRasterExecutor().admits(poisoned))
        let surface = try #require(MacBitmapSurface(poisoned))
        #expect(!surface.draw(poisoned))
    }
}
