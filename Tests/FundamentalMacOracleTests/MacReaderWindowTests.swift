import AppKit
import Testing

@testable import FundamentalMacOracle

@Suite("The native macOS summit window", .serialized)
@MainActor
struct MacReaderWindowTests
{
    @Test(
        "native windows center the fixed measure",
        arguments: [820.0, 1_200.0]
    )
    func nativeWindowCentersMeasure(width: Double) throws
    {
        let controller = try MacOracleTestSurface.window(width: width)
        let window = try #require(controller.window)
        controller.showWindow(nil)
        controller.synchronize()
        #expect(window.styleMask.contains(.titled))
        #expect(window.styleMask.contains(.closable))
        #expect(window.styleMask.contains(.miniaturizable))
        #expect(window.styleMask.contains(.resizable))
        #expect(window.toolbar == nil)
        #expect(controller.scrollView.hasVerticalScroller)
        #expect(controller.readerView.model.readableMeasure == 720)
        let expected = max(
            0,
            (controller.readerView.bounds.width - 720) / 2
        )
        #expect(abs(
            controller.readerView.horizontalInset - expected
        ) < 0.001)
        window.close()
    }

    @Test("a far scroll survives a shorter wide relayout")
    func farScrollSurvivesWideRelayout() throws
    {
        let controller = try MacOracleTestSurface.window(
            width: 600,
            height: 300
        )
        let window = try #require(controller.window)
        controller.showWindow(nil)
        let clip = controller.scrollView.contentView
        clip.scroll(to: NSPoint(
            x: 0,
            y: controller.readerView.model.documentHeight
        ))
        controller.synchronize()
        window.setContentSize(NSSize(width: 1_200, height: 300))
        controller.synchronize()
        let maximum = max(
            0,
            controller.readerView.model.documentHeight
                - clip.bounds.height
        )
        #expect(clip.bounds.minY <= maximum)
        #expect(controller.readerView.model.visibleOriginY <= maximum)
        window.close()
    }
}
