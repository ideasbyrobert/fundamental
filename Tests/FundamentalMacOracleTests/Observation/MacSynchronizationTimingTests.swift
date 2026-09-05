import AppKit
import Testing

@testable import FundamentalMacOracle

@Suite("Native synchronization timing observations", .serialized)
@MainActor
struct MacSynchronizationTimingTests
{
    @Test(
        "release observations separate synchronization from bitmap drawing",
        .enabled(if: ProcessInfo.processInfo.environment[
            "FUNDAMENTAL_NATIVE_OBSERVATION"
        ] == "1")
    )
    func timing() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        let view = controller.readerView
        let clip = controller.scrollView.contentView
        let layouts = view.model.layoutExecutionCount
        try MacSynchronizationTiming.measure("equal")
        {
            _ in
            view.synchronizeFromScrollView()
        }
        try MacSynchronizationTiming.measure("wide-resize")
        {
            index in
            let previous = clip.bounds.width
            window.setContentSize(NSSize(
                width: index.isMultiple(of: 2) ? 1_200 : 820,
                height: 680
            ))
            return clip.bounds.width != previous
                && view.synchronizeFromScrollView()
        }
        let origins = [24.0, 48.0, 24.0, 0.0]
        try MacSynchronizationTiming.measure("short-scroll")
        {
            index in
            let previous = clip.bounds.minY
            clip.scroll(to: NSPoint(x: 0, y: origins[index % 4]))
            controller.scrollView.reflectScrolledClipView(clip)
            return clip.bounds.minY != previous
                && view.synchronizeFromScrollView()
        }
        #expect(view.model.layoutExecutionCount == layouts)
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
        let execution = view.model.rasterExecution
        let bitmap = try #require(MacBitmapSurface(view.model.snapshot))
        try MacSynchronizationTiming.measure("bitmap")
        {
            _ in
            bitmap.draw(execution)
            return true
        }
        #expect(bitmap.containsInk(in: bitmap.pixelBounds))
        MacReaderRasterPublicationTests.expectSameExecution(
            execution,
            view.model.rasterExecution
        )
    }
}
