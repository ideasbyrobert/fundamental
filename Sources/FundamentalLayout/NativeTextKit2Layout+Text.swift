import AppKit
import CoreText
import FundamentalProjection

extension NativeTextKit2Layout
{
    func proseLines(
        _ prose: ProjectedProse,
        source: ProjectedBlockSource,
        width: Double,
        originY: Double
    ) throws -> [LayoutLine]
    {
        try textLines(
            runs: prose.runs,
            width: width,
            originX: 0,
            originY: originY,
            font: try proseFont(prose.role),
            pointContext: .block(source.blockID)
        )
    }

    func codeLines(
        _ code: ProjectedCode,
        source: ProjectedBlockSource,
        width: Double,
        originY: Double
    ) throws -> [LayoutLine]
    {
        try textLines(
            runs: code.runs,
            width: width,
            originX: 0,
            originY: originY,
            font: .monospacedSystemFont(
                ofSize: 15,
                weight: .regular
            ),
            pointContext: .block(source.blockID)
        )
    }

    func textLines(
        runs: [ProjectedRun],
        width: Double,
        originX: Double,
        originY: Double,
        font: NSFont,
        pointContext: NativeTextPointContext
    ) throws -> [LayoutLine]
    {
        let attributed = NSMutableAttributedString(string: "")
        var segments: [NativeSourceSegment] = []
        var offset = 0
        for run in runs
        {
            let length = run.text.utf16.count
            attributed.append(NSAttributedString(
                string: run.text,
                attributes: try attributes(
                    font: font,
                    traits: run.traits
                )
            ))
            segments.append(NativeSourceSegment(
                source: run.source,
                localRange: offset ..< offset + length,
                sourceLowerBound: sourceRange(run.source).lowerBound
            ))
            offset += length
        }
        let storage = NSTextContentStorage()
        let manager = NSTextLayoutManager()
        let container = NSTextContainer(size: CGSize(
            width: width,
            height: .greatestFiniteMagnitude
        ))
        container.lineFragmentPadding = 0
        storage.addTextLayoutManager(manager)
        manager.textContainer = container
        storage.attributedString = attributed
        manager.ensureLayout(for: storage.documentRange)
        let text = attributed.string as NSString
        let defaultFont = try fontIdentity(font as CTFont)
        var lines: [LayoutLine] = []
        var failure: LayoutFailure? = nil
        manager.enumerateTextLayoutFragments(
            from: storage.documentRange.location,
            options: [.ensuresLayout, .ensuresExtraLineFragment]
        )
        {
            fragment in
            let base = storage.offset(
                from: storage.documentRange.location,
                to: fragment.rangeInElement.location
            )
            for nativeLine in fragment.textLineFragments
            {
                let local = nativeLine.characterRange
                guard local.location != NSNotFound
                else
                {
                    failure = .invalidNativeSourceRange
                    return false
                }
                let range = NSRange(
                    location: base + local.location,
                    length: local.length
                )
                do
                {
                    lines.append(try line(
                        nativeLine,
                        fragment: fragment,
                        range: range,
                        attributed: attributed,
                        text: text,
                        segments: segments,
                        defaultFont: defaultFont,
                        originX: originX,
                        originY: originY,
                        pointContext: pointContext
                    ))
                }
                catch let caught as LayoutFailure
                {
                    failure = caught
                    return false
                }
                catch
                {
                    failure = .invalidNativeSourceRange
                    return false
                }
            }
            return true
        }
        if let failure
        {
            throw failure
        }
        guard !lines.isEmpty
        else
        {
            throw LayoutFailure.missingNativeLine
        }
        return lines
    }

    func line(
        _ nativeLine: NSTextLineFragment,
        fragment: NSTextLayoutFragment,
        range: NSRange,
        attributed: NSAttributedString,
        text: NSString,
        segments: [NativeSourceSegment],
        defaultFont: LayoutFontIdentity,
        originX: Double,
        originY: Double,
        pointContext: NativeTextPointContext
    ) throws -> LayoutLine
    {
        guard NSMaxRange(range) <= attributed.length
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        let fragmentFrame = fragment.layoutFragmentFrame
        let bounds = nativeLine.typographicBounds
        let lineX = originX + fragmentFrame.minX + bounds.minX
        let lineY = originY + fragmentFrame.minY + bounds.minY
        let frame = try rectangle(
            x: lineX,
            y: lineY,
            width: bounds.width,
            height: bounds.height
        )
        let glyph = nativeLine.glyphOrigin
        let baseline = try point(
            x: lineX + glyph.x,
            y: lineY + glyph.y
        )
        let sourceSlices = slices(
            for: range,
            segments: segments,
            text: text
        )
        let substring = attributed.attributedSubstring(from: range)
        let lineText = text.substring(with: range)
        guard sourceSlices.map(\.text).joined() == lineText,
              sourceSlices.reduce(0, { $0 + $1.range.count })
                == range.length
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        let caretStops = try caretStops(
            nativeLine,
            text: lineText,
            originX: lineX,
            originY: lineY,
            nativeOffset: nativeLine.characterRange.location,
            containerOffset: range.location,
            pointContext: pointContext
        )
        let caretXs = caretStops.map(\.position.x)
        let textKitAdvance = caretXs.max()! - caretXs.min()!
        return LayoutLine(
            text: lineText,
            frame: frame,
            baseline: baseline,
            sourceSlices: sourceSlices,
            firstCaretStop: caretStops[0],
            remainingCaretStops: Array(caretStops.dropFirst()),
            defaultFont: defaultFont,
            glyphRuns: try glyphRuns(
                substring,
                textKitAdvance: textKitAdvance,
                documentOffset: range.location,
                baseline: baseline,
                segments: segments,
                text: text
            )
        )
    }

    func caretStops(
        _ nativeLine: NSTextLineFragment,
        text: String,
        originX: Double,
        originY: Double,
        nativeOffset: Int,
        containerOffset: Int,
        pointContext: NativeTextPointContext
    ) throws -> [LayoutCaretStop]
    {
        var offsets = [0]
        var offset = 0
        for character in text
        {
            offset += String(character).utf16.count
            offsets.append(offset)
        }
        return try offsets.map
        {
            offset in
            let location = nativeLine.locationForCharacter(
                at: nativeOffset + offset
            )
            return LayoutCaretStop(
                utf16Offset: offset,
                position: try point(
                    x: originX + location.x,
                    y: originY + location.y
                ),
                sourcePoint: textPoint(
                    pointContext,
                    utf16Offset: containerOffset + offset
                )
            )
        }
    }

    func textPoint(
        _ context: NativeTextPointContext,
        utf16Offset: Int
    ) -> LayoutTextPoint
    {
        switch context
        {
        case let .block(blockID):
            .block(
                blockID: blockID,
                utf16Offset: utf16Offset
            )
        case let .caption(blockID):
            .caption(
                blockID: blockID,
                utf16Offset: utf16Offset
            )
        case let .cell(blockID, row, cell):
            .cell(
                blockID: blockID,
                row: row,
                cell: cell,
                utf16Offset: utf16Offset
            )
        }
    }
}
