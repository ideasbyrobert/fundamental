import AppKit
import CoreText

extension NativeTextKit2Layout
{
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
