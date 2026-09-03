import AppKit
import CoreText

extension NativeTextKit2Layout
{
    func glyphRuns(
        _ attributed: NSAttributedString,
        textKitAdvance: Double,
        documentOffset: Int,
        baseline: LayoutPoint,
        segments: [NativeSourceSegment],
        text: NSString
    ) throws -> [LayoutGlyphRun]
    {
        let line = CTLineCreateWithAttributedString(attributed)
        let shapedAdvance = CTLineGetTypographicBounds(
            line,
            nil,
            nil,
            nil
        )
        guard shapedAdvance.isFinite,
              abs(shapedAdvance - textKitAdvance) < 0.5
        else
        {
            throw LayoutFailure.inconsistentNativeShaping(
                textKitWidth: textKitAdvance,
                coreTextWidth: shapedAdvance
            )
        }
        let nativeRuns = CTLineGetGlyphRuns(line) as NSArray
        var result: [LayoutGlyphRun] = []
        for paintOrder in 0 ..< nativeRuns.count
        {
            let nativeRun = nativeRuns[paintOrder] as! CTRun
            if let run = try glyphRun(
                nativeRun,
                attributed: attributed,
                documentOffset: documentOffset,
                baseline: baseline,
                segments: segments,
                text: text,
                paintOrder: paintOrder
            )
            {
                result.append(run)
            }
        }
        return result
    }

    func glyphRun(
        _ run: CTRun,
        attributed: NSAttributedString,
        documentOffset: Int,
        baseline: LayoutPoint,
        segments: [NativeSourceSegment],
        text: NSString,
        paintOrder: Int
    ) throws -> LayoutGlyphRun?
    {
        let count = CTRunGetGlyphCount(run)
        guard count > 0
        else
        {
            return nil
        }
        let runRange = CTRunGetStringRange(run)
        guard runRange.location >= 0,
              runRange.length >= 0,
              runRange.location + runRange.length <= attributed.length
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        var nativeGlyphs = [CGGlyph](repeating: 0, count: count)
        var positions = [CGPoint](repeating: .zero, count: count)
        var advances = [CGSize](repeating: .zero, count: count)
        var indices = [CFIndex](repeating: kCFNotFound, count: count)
        let entireRun = CFRange(location: 0, length: 0)
        CTRunGetGlyphs(run, entireRun, &nativeGlyphs)
        CTRunGetPositions(run, entireRun, &positions)
        CTRunGetAdvances(run, entireRun, &advances)
        CTRunGetStringIndices(run, entireRun, &indices)
        let attributes = CTRunGetAttributes(run) as NSDictionary
        guard let font = attributes.object(
            forKey: kCTFontAttributeName
        ) as! CTFont?
        else
        {
            throw LayoutFailure.missingResolvedFontIdentity
        }
        let identity = try fontIdentity(font)
        let style = runStyle(
            attributed,
            runRange: runRange
        )
        let globalRange = NSRange(
            location: documentOffset + runRange.location,
            length: runRange.length
        )
        let runSlices = slices(
            for: globalRange,
            segments: segments,
            text: text
        )
        let logicalIndices = Set(indices.filter
        {
            $0 >= runRange.location &&
                $0 < runRange.location + runRange.length
        }).sorted()
        let glyphs = try nativeGlyphs.indices.map
        {
            index in
            let nativePosition = positions[index]
            let nativeAdvance = advances[index]
            guard nativePosition.x.isFinite,
                  nativePosition.y.isFinite,
                  nativeAdvance.width.isFinite,
                  nativeAdvance.height.isFinite
            else
            {
                throw LayoutFailure.nonfiniteNativeGeometry
            }
            return LayoutGlyph(
                identifier: UInt32(nativeGlyphs[index]),
                position: try point(
                    x: baseline.x + nativePosition.x,
                    y: baseline.y - nativePosition.y
                        - style.baselineOffset
                ),
                advance: LayoutVector(
                    dx: nativeAdvance.width,
                    dy: -nativeAdvance.height
                ),
                sourceSlices: try glyphSlices(
                    stringIndex: indices[index],
                    logicalIndices: logicalIndices,
                    runRange: runRange,
                    documentOffset: documentOffset,
                    segments: segments,
                    text: text
                )
            )
        }
        let textMatrix = CTRunGetTextMatrix(run)
        guard [
            textMatrix.a,
            textMatrix.b,
            textMatrix.c,
            textMatrix.d,
            textMatrix.tx,
            textMatrix.ty
        ].allSatisfy(\.isFinite)
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        return LayoutGlyphRun(
            paintOrder: paintOrder,
            font: identity,
            textMatrix: LayoutAffineTransform(
                a: textMatrix.a,
                b: textMatrix.b,
                c: textMatrix.c,
                d: textMatrix.d,
                tx: textMatrix.tx,
                ty: textMatrix.ty
            ),
            style: style,
            sourceSlices: runSlices,
            decorations: try decorations(
                attributed,
                runRange: runRange,
                font: identity,
                baseline: baseline,
                positions: positions,
                advances: advances,
                sourceSlices: runSlices
            ),
            firstGlyph: glyphs[0],
            remainingGlyphs: Array(glyphs.dropFirst())
        )
    }

    func glyphSlices(
        stringIndex: CFIndex,
        logicalIndices: [CFIndex],
        runRange: CFRange,
        documentOffset: Int,
        segments: [NativeSourceSegment],
        text: NSString
    ) throws -> [LayoutSourceSlice]
    {
        if stringIndex == kCFNotFound
        {
            return []
        }
        guard let position = logicalIndices.firstIndex(of: stringIndex)
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        let upper: Int
        if position + 1 < logicalIndices.count
        {
            upper = logicalIndices[position + 1]
        }
        else
        {
            upper = runRange.location + runRange.length
        }
        guard stringIndex >= runRange.location,
              stringIndex < upper,
              upper <= runRange.location + runRange.length
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        let mapped = slices(
            for: NSRange(
                location: documentOffset + stringIndex,
                length: upper - stringIndex
            ),
            segments: segments,
            text: text
        )
        guard !mapped.isEmpty,
              mapped.reduce(0, { $0 + $1.text.utf16.count })
                == upper - stringIndex
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        return mapped
    }
}
