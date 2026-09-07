import AppKit

extension WritingTextView
{
    func listMarkers(in rectangle: NSRect) -> [WritingListMarker]
    {
        guard hasListMarkers, let layout = textLayoutManager
        else
        {
            return []
        }
        var markers: [WritingListMarker] = []
        let start = layout.textViewportLayoutController.viewportRange?.location
        let origin = textContainerOrigin
        layout.enumerateTextLayoutFragments(
            from: start, options: []
        )
        {
            fragment in
            let frame = fragment.layoutFragmentFrame
            if frame.minY + origin.y > rectangle.maxY
            {
                return false
            }
            for line in fragment.textLineFragments
            {
                guard line.characterRange.location == 0 ||
                    line.characterRange.length == 0
                else
                {
                    continue
                }
                let text = line.attributedString
                let index = line.characterRange.location
                let attributes = index < text.length ?
                    text.attributes(at: index, effectiveRange: nil) :
                    terminalAttributes
                if let marker = WritingListMarker(
                    beside: line, attributes: attributes,
                    paragraphOrigin: CGPoint(
                        x: origin.x + frame.minX, y: origin.y + frame.minY
                    )
                ), marker.frame.intersects(rectangle)
                {
                    markers.append(marker)
                }
            }
            return true
        }
        return markers
    }
}
