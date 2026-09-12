import AppKit

extension WritingWindowController
{
    @objc func zoomIn(_ sender: Any?)
    {
        applyZoom(bridge.zoom.increased)
    }

    @objc func zoomOut(_ sender: Any?)
    {
        applyZoom(bridge.zoom.decreased)
    }

    @objc func actualSize(_ sender: Any?)
    {
        applyZoom(WritingZoom())
    }

    @discardableResult
    func applyZoom(_ zoom: WritingZoom) -> Bool
    {
        guard !choosingLocation, !hasFormattingSheet, closeTask == nil,
              bridge.setZoom(zoom, in: textView)
        else
        {
            return false
        }
        zoomPreferences?.store(zoom)
        textView.setAccessibilityHelp("Writing at \(zoom.percentage)% zoom.")
        updateWritingGeometry()
        return true
    }

    func validateZoom(_ item: NSValidatedUserInterfaceItem) -> Bool
    {
        guard !choosingLocation, !hasFormattingSheet, closeTask == nil
        else
        {
            return false
        }
        switch item.action
        {
        case #selector(zoomIn(_:)):
            return bridge.zoom.canIncrease
        case #selector(zoomOut(_:)):
            return bridge.zoom.canDecrease
        case #selector(actualSize(_:)):
            (item as? NSMenuItem)?.state = bridge.zoom.percentage == 100
                ? .on : .off
            return true
        default:
            return false
        }
    }
}
