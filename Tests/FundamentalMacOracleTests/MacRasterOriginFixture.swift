import AppKit
import CoreText
import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

@MainActor
enum MacRasterOriginFixture
{
    static func line(
        for batch: PresentationGlyphBatch, in snapshot: PresentationSnapshot
    ) throws -> PresentedTextLine
    {
        let residents = snapshot.presentedDocument.residents.all.filter
        {
            $0.residentID == batch.residentID
        }
        #expect(residents.count == 1)
        let resident = try #require(residents.first)
        switch resident.content
        {
        case let .body(line), let .title(line), let .section(_, line),
             let .code(line), let .caption(line):
            return line
        case let .headerCell(_, _, .line(line)),
             let .bodyCell(_, _, .line(line)):
            return line
        default:
            throw MacOracleTestFailure.admission
        }
    }

    static func nativeLine(_ batch: PresentationGlyphBatch) throws -> CTLine
    {
        let text = batch.sourceSlices.map(\.text).joined()
        let font = try #require(MacAdmittedFont(batch.font, sourceText: text))
        let line = CTLineCreateWithAttributedString(NSAttributedString(
            string: text, attributes: [.font: font.native]
        ))
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        var glyphs: [UInt32] = []
        for run in runs
        {
            let count = CTRunGetGlyphCount(run)
            var identifiers = [CGGlyph](repeating: 0, count: count)
            CTRunGetGlyphs(run, CFRange(location: 0, length: 0), &identifiers)
            glyphs += identifiers.map(UInt32.init)
        }
        #expect(glyphs == batch.glyphs.map(\.identifier))
        return line
    }
}
