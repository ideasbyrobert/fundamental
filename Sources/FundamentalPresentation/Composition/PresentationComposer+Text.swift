import FundamentalRaster

extension PresentationComposer
{
    static func textLine(
        _ value: RasterInteractionText
    ) -> PresentedTextLine?
    {
        guard value.marker == nil,
              let font = font(value.defaultFont),
              let bounds = rectangle(value.lineBounds),
              bounds.size.height > 0,
              let baseline = point(value.baseline),
              let slices = sourceSlices(value.sourceSlices),
              let firstCaret = caretSite(value.firstCaretSite)
        else
        {
            return nil
        }
        var carets = [firstCaret]
        carets.reserveCapacity(1 + value.remainingCaretSites.count)
        for value in value.remainingCaretSites
        {
            guard let caret = caretSite(value)
            else
            {
                return nil
            }
            carets.append(caret)
        }
        guard validText(
            value.text,
            slices: slices,
            carets: carets
        )
        else
        {
            return nil
        }
        return PresentedTextLine(
            text: value.text,
            defaultFont: font,
            lineBounds: bounds,
            baseline: baseline,
            sourceSlices: slices,
            firstCaretSite: firstCaret,
            remainingCaretSites: Array(carets.dropFirst())
        )
    }
}
