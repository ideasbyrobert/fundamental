import AppKit
import FundamentalPresentation

extension MacAccessibilityTree
{
    static func listItem(
        _ residents: [PresentedResident],
        view: NSView, horizontalInset: Double
    ) -> MacAccessibilityElement?
    {
        guard let first = residents.first,
              let item = first.content.listItem
        else
        {
            return nil
        }
        let frames = residents.map
        {
            screenFrame($0, view: view, horizontalInset: horizontalInset)
        }
        let frame = frames.dropFirst().reduce(frames[0])
        {
            $0.union($1)
        }
        let group = element(.listItem(item), frame: frame, parent: view)
        var children: [MacAccessibilityElement] = []
        if let marker = first.content.listMarker
        {
            children.append(element(
                .listMarker(item),
                frame: markerFrame(
                    marker, view: view, horizontalInset: horizontalInset
                ),
                parent: group
            ))
        }
        let source = residents.compactMap(\.content.textLine)
            .map(\.text).joined()
        children.append(element(
            .listText(item, source), frame: frame, parent: group
        ))
        group.replaceChildren(children)
        return group
    }

    static func markerFrame(
        _ marker: PresentationListMarker,
        view: NSView, horizontalInset: Double
    ) -> NSRect
    {
        let local = NSRect(
            x: marker.inkBounds.minX + horizontalInset,
            y: marker.inkBounds.minY,
            width: marker.inkBounds.size.width,
            height: marker.inkBounds.size.height
        )
        let windowFrame = view.convert(local, to: nil)
        return view.window?.convertToScreen(windowFrame) ?? windowFrame
    }
}
