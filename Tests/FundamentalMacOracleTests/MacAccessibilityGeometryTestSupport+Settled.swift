import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacAccessibilityGeometryTestSupport
{
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
