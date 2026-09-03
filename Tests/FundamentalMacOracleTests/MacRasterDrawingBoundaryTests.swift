import Foundation
import Testing

extension MacOracleArchitectureTests
{
    @Test("native drawing consumes only an admitted execution")
    func drawingConsumesOnlyAdmittedExecution() throws
    {
        let source = try MacOracleRepository.source(
            "Sources/FundamentalMacOracle/Raster/"
                + "MacRasterExecutor+Drawing.swift"
        )
        #expect(source.contains(
            "_ execution: MacAdmittedRasterExecution"
        ))
        let forbidden = [
            "PresentationSnapshot",
            "admit("
        ]
        for value in forbidden
        {
            #expect(!source.contains(value))
        }
        let expression = try NSRegularExpression(
            pattern: #"\b([A-Za-z_][A-Za-z0-9_]*)\s*\("#
        )
        let range = NSRange(source.startIndex..., in: source)
        let calls = Set(expression.matches(in: source, range: range)
            .compactMap
        {
            Range($0.range(at: 1), in: source).map
            {
                String(source[$0])
            }
        })
        let admittedCalls: Set<String> = [
            "CGAffineTransform",
            "CTFontDrawGlyphs",
            "caret",
            "clip",
            "contains",
            "draw",
            "drawCaret",
            "drawMarks",
            "drawSelection",
            "fill",
            "glyphs",
            "insert",
            "restoreGState",
            "saveGState",
            "selection",
            "setFillColor",
            "setTextDrawingMode",
            "translateBy"
        ]
        #expect(calls == admittedCalls)
    }
}
