import AppKit
import Testing

@testable import FundamentalMacOracle

@Suite("Native accessibility geometry publication", .serialized)
@MainActor
struct MacAccessibilityGeometryTests
{
    @Test("an unattached reader publishes no provisional nodes")
    func unattachedReaderPublishesNoNodes() throws
    {
        let model = try MacOracleTestSurface.model()
        let view = MacReaderView(
            frame: NSRect(x: 0, y: 0, width: 820, height: 680),
            model: model
        )
        let generation = model.snapshot.lineage.generation
        let layoutExecutions = model.layoutExecutionCount
        let elements = try #require(
            view.accessibilityChildren() as? [MacAccessibilityElement]
        )
        #expect(elements.isEmpty)
        #expect(model.snapshot.lineage.generation == generation)
        #expect(model.layoutExecutionCount == layoutExecutions)
    }

    @Test(
        "attached narrow and wide readers publish final native frames",
        arguments: [820.0, 1_200.0]
    )
    func attachedReadersPublishFinalFrames(width: Double) throws
    {
        let controller = try MacOracleTestSurface.window(width: width)
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
    }

    @Test("window movement rebuilds only screen geometry")
    func windowMovementRebuildsOnlyScreenGeometry() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        let view = controller.readerView
        let beforeElement = try MacAccessibilityGeometryTestSupport
            .firstElement(view)
        let beforeFrame = try MacAccessibilityGeometryTestSupport
            .frame(beforeElement)
        let beforeOrigin = window.frame.origin
        let generation = view.model.snapshot.lineage.generation
        let layoutExecutions = view.model.layoutExecutionCount
        window.setFrameOrigin(NSPoint(
            x: beforeOrigin.x + 37,
            y: beforeOrigin.y + 29
        ))
        let afterElement = try MacAccessibilityGeometryTestSupport
            .firstElement(view)
        let afterFrame = try MacAccessibilityGeometryTestSupport
            .frame(afterElement)
        let deltaX = window.frame.minX - beforeOrigin.x
        let deltaY = window.frame.minY - beforeOrigin.y
        #expect(afterElement !== beforeElement)
        #expect(afterFrame.minX == beforeFrame.minX + deltaX)
        #expect(afterFrame.minY == beforeFrame.minY + deltaY)
        #expect(afterFrame.size == beforeFrame.size)
        #expect(view.model.snapshot.lineage.generation == generation)
        #expect(view.model.layoutExecutionCount == layoutExecutions)
    }
}
