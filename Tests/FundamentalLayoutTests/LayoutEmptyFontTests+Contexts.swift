import AppKit
import Testing

@testable import FundamentalLayout

extension LayoutEmptyFontTests
{
    @MainActor
    @Test("empty source keeps translated block, caption and cell carets")
    func sourceContexts() throws
    {
        let native = NativeTextKit2Layout()
        let blockID = LayoutFixture.blockID(0)
        let contexts: [(NativeTextPointContext, LayoutTextPoint)] = [
            (.block(blockID), .block(blockID: blockID, utf16Offset: 0)),
            (.caption(blockID), .caption(blockID: blockID, utf16Offset: 0)),
            (.cell(blockID: blockID, row: 2, cell: 3),
             .cell(blockID: blockID, row: 2, cell: 3, utf16Offset: 0))
        ]
        let font = NSFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        for (context, expected) in contexts
        {
            let zero = try #require(native.textLines(
                runs: [], width: 120, originX: 0, originY: 0,
                font: font, pointContext: context
            ).first)
            let shifted = try #require(native.textLines(
                runs: [], width: 120, originX: 19, originY: 37,
                font: font, pointContext: context
            ).first)
            let translated = try native.translated(zero, dx: 19, dy: 37)
            #expect(shifted == translated)
            #expect(shifted.firstCaretStop.sourcePoint == expected)
            #expect(shifted.firstCaretStop.position == shifted.baseline)
            #expect(shifted.frame.minX == 19)
            #expect(shifted.frame.minY == 37)
            #expect(shifted.text.isEmpty && shifted.glyphRuns.isEmpty)
            #expect(throws: LayoutFailure.nonfiniteNativeGeometry)
            {
                try native.textLines(
                    runs: [], width: 120, originX: .infinity, originY: 0,
                    font: font, pointContext: context
                )
            }
        }
    }
}
