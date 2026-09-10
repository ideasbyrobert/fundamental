import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacReaderListTests
{
    @Test("native marker accessibility frames identify generated ink")
    func markerAccessibilityFrames() throws
    {
        let source = try MacReaderDocumentFixture.source([
            MacReaderListFixture.block(.numbered, "First line\nSecond line")
        ])
        let controller = try MacReaderDocumentFixture.window(source)
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        controller.synchronize()
        let view = controller.readerView
        let groups = try MacReaderListFixture.groups(view)
        let group = try #require(groups.first)
        let nodes = try MacReaderListFixture.children(group)
        let prefix = try #require(nodes.first)
        let sourceMarker = try #require(view.model.snapshot.presentedDocument
            .residents.first.content.listMarker)
        let frame = try MacAccessibilityGeometryTestSupport.frame(prefix)
        let local = view.convert(window.convertFromScreen(frame), from: nil)
        #expect(abs(local.minX - sourceMarker.inkBounds.minX
            - view.horizontalInset) < 1e-6)
        #expect(abs(local.minY - sourceMarker.inkBounds.minY) < 1e-6)
        #expect(abs(local.width - sourceMarker.inkBounds.size.width) < 1e-6)
        #expect(abs(local.height - sourceMarker.inkBounds.size.height) < 1e-6)
        #expect(group.accessibilityAttributeValue(.parent) as? NSView === view)
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
    }

    @Test("retained accessible text survives the release of its list group")
    func releasedAccessibilityParent() throws
    {
        let source = try MacReaderDocumentFixture.source([
            MacReaderListFixture.block(.numbered, "Retained source")
        ])
        let model = try MacReaderDocumentFixture.model(source)
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 820, height: 680))
        var nodes = MacAccessibilityTree.elements(
            document: model.snapshot.presentedDocument,
            view: view, horizontalInset: 0
        )
        weak let group = nodes.first
        let child: MacAccessibilityElement
        do
        {
            let parent = try #require(nodes.first)
            let children = try MacReaderListFixture.children(parent)
            child = try #require(children.last)
        }
        #expect(group != nil)
        nodes.removeAll()
        #expect(group == nil)
        #expect(child.accessibilityAttributeValue(.parent) == nil)
        #expect(child.accessibilityAttributeValue(.value) as? String
            == "Retained source")
    }
}
