import CoreText
import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

@Suite("Native glyph drawing from retained line origins")
@MainActor
struct MacRasterOriginTests
{
    @Test("the actual executor reproduces native color emoji pixels")
    func colorEmojiNativePixels() throws
    {
        for scale in [1.0, 2]
        {
            let snapshot = try MacOracleTestSurface.snapshot(
                backingScale: scale
            )
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
            for (index, batch) in batches.enumerated()
            {
                for offset in [0.0, 0.25]
                {
                    let (shifted, glyphs) = try MacRasterOriginFixture.shift(
                        batch, in: snapshot, x: offset, y: 2 * offset
                    )
                    try compareNativePixels(
                        glyphs, in: shifted,
                        label: "\(Int(scale))-\(index)-\(offset)"
                    )
                }
            }
        }
    }
}
