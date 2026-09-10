import AppKit

extension NativeTextKit2Layout
{
    func selectionExtent(
        storage: NSTextContentStorage, manager: NSTextLayoutManager,
        fragment: NSTextLayoutFragment, line: NSTextLineFragment,
        originX: Double
    ) throws -> LayoutSelectionExtent
    {
        guard let container = manager.textContainer,
              let location = storage.location(
                  fragment.rangeInElement.location,
                  offsetBy: line.characterRange.location
              )
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        let padding = Double(container.lineFragmentPadding)
        let left = originX + padding
        let right = originX + Double(container.size.width) - padding
        let extent: LayoutSelectionExtent?
        switch manager.baseWritingDirection(at: location)
        {
        case .leftToRight:
            extent = LayoutSelectionExtent(leading: left, trailing: right)
        case .rightToLeft:
            extent = LayoutSelectionExtent(leading: right, trailing: left)
        @unknown default:
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        guard left <= right, let extent
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        return extent
    }

    func translated(
        _ extent: LayoutSelectionExtent, dx: Double
    ) throws -> LayoutSelectionExtent
    {
        guard let result = LayoutSelectionExtent(
            leading: extent.leading + dx, trailing: extent.trailing + dx
        )
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        return result
    }
}
