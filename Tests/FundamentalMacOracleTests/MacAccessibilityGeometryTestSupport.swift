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
        let local = NSRect(
            x: resident.frame.minX + view.horizontalInset,
            y: resident.frame.minY,
            width: resident.frame.size.width,
            height: resident.frame.size.height
        )
        let windowFrame = view.convert(local, to: nil)
        let window = try #require(view.window)
        return window.convertToScreen(windowFrame)
    }

    static func expectSettled(
        _ controller: MacReaderWindowController
    ) throws
    {
        let view = controller.readerView
        let clip = controller.scrollView.contentView
        let actual = try frame(firstElement(view))
        let expected = try expectedFirstFrame(view)
        let expectedHeight = max(
            clip.bounds.height,
            view.model.documentHeight
        )
        #expect(view.frame.width.bitPattern
            == clip.bounds.width.bitPattern)
        #expect(view.frame.height.bitPattern
            == expectedHeight.bitPattern)
        #expect(clip.bounds.minY.bitPattern
            == view.model.visibleOriginY.bitPattern)
        #expect(actual.minX.bitPattern == expected.minX.bitPattern)
        #expect(actual.minY.bitPattern == expected.minY.bitPattern)
        #expect(actual.width.bitPattern == expected.width.bitPattern)
        #expect(actual.height.bitPattern == expected.height.bitPattern)
    }
}
