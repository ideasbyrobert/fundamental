import AppKit
import CoreText

extension NativeTextKit2Layout
{
    func runStyle(
        _ attributed: NSAttributedString,
        runRange: CFRange
    ) -> LayoutRunStyle
    {
        let attributes = attributed.attributes(
            at: runRange.location,
            effectiveRange: nil
        )
        let baselineOffset = (
            attributes[.baselineOffset] as? NSNumber
        )?.doubleValue ?? 0
        return LayoutRunStyle(baselineOffset: baselineOffset)
    }

    func decorations(
        _ attributed: NSAttributedString,
        runRange: CFRange,
        font: LayoutFontIdentity,
        baseline: LayoutPoint,
        positions: [CGPoint],
        advances: [CGSize],
        sourceSlices: [LayoutSourceSlice]
    ) throws -> [LayoutDecoration]
    {
        let attributes = attributed.attributes(
            at: runRange.location,
            effectiveRange: nil
        )
        let underline = (
            attributes[.underlineStyle] as? NSNumber
        )?.intValue ?? 0
        let strikethrough = (
            attributes[.strikethroughStyle] as? NSNumber
        )?.intValue ?? 0
        guard underline != 0 || strikethrough != 0
        else
        {
            return []
        }
        let style = runStyle(attributed, runRange: runRange)
        let horizontal = zip(positions, advances).flatMap
        {
            position, advance in
            [
                baseline.x + position.x,
                baseline.x + position.x + advance.width
            ]
        }
        guard let minimumX = horizontal.min(),
              let maximumX = horizontal.max()
        else
        {
            return []
        }
        let thickness = abs(font.metrics.underlineThickness)
        var result: [LayoutDecoration] = []
        if underline != 0
        {
            let center = baseline.y - style.baselineOffset
                - font.metrics.underlinePosition
            result.append(LayoutDecoration(
                kind: .underline,
                frame: try rectangle(
                    x: minimumX,
                    y: center - thickness * 0.5,
                    width: maximumX - minimumX,
                    height: thickness
                ),
                sourceSlices: sourceSlices
            ))
        }
        if strikethrough != 0
        {
            let center = baseline.y - style.baselineOffset
                - font.metrics.xHeight * 0.5
            result.append(LayoutDecoration(
                kind: .strikethrough,
                frame: try rectangle(
                    x: minimumX,
                    y: center - thickness * 0.5,
                    width: maximumX - minimumX,
                    height: thickness
                ),
                sourceSlices: sourceSlices
            ))
        }
        return result
    }
}
