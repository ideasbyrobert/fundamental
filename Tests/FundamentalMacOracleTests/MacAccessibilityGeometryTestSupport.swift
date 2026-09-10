import AppKit
import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

@MainActor
enum MacAccessibilityGeometryTestSupport
{
    static func firstElement(
        _ view: MacReaderView
    ) throws -> MacAccessibilityElement
    {
        let elements = try #require(
            view.accessibilityChildren() as? [MacAccessibilityElement]
        )
        return try #require(elements.first)
    }

    static func frame(
        _ element: MacAccessibilityElement
    ) throws -> NSRect
    {
        let position = try #require(element.accessibilityAttributeValue(
            .position
        ) as? NSValue).pointValue
        let size = try #require(element.accessibilityAttributeValue(
            .size
        ) as? NSValue).sizeValue
        return NSRect(origin: position, size: size)
    }

    static func expectedFirstFrame(
        _ view: MacReaderView
    ) throws -> NSRect
    {
        let resident = try #require(
            view.model.snapshot.presentedDocument.residents.all.first
            {
                switch $0.content
                {
                case .body,
                     .title,
                     .section,
                     .code,
                     .list,
                     .table:
                    true
                case .caption,
                     .tableColumn,
                     .headerRow,
                     .bodyRow,
                     .headerCell,
                     .bodyCell:
                    false
                }
            }
        )
        var local = NSRect(
            x: resident.frame.minX + view.horizontalInset,
            y: resident.frame.minY,
            width: resident.frame.size.width,
            height: resident.frame.size.height
        )
        if resident.content.listItem != nil
        {
            let fragments = view.model.snapshot.presentedDocument.residents
                .all.filter
            {
                $0.residentID.blockID == resident.residentID.blockID
            }
            for fragment in fragments
            {
                local = local.union(NSRect(
                    x: fragment.frame.minX + view.horizontalInset,
                    y: fragment.frame.minY,
                    width: fragment.frame.size.width,
                    height: fragment.frame.size.height
                ))
            }
        }
        let windowFrame = view.convert(local, to: nil)
        let window = try #require(view.window)
        return window.convertToScreen(windowFrame)
    }

}
