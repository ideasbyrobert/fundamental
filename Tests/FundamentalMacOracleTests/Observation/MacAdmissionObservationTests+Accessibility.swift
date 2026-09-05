import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacAdmissionObservationTests
{
    @Test("accessibility construction observes already settled coordinates")
    func accessibility() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        let view = controller.readerView
        try #require(view.synchronizeFromScrollView())
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
        let snapshot = view.model.snapshot
        let execution = view.model.rasterExecution
        let layouts = view.model.layoutExecutionCount
        MacAdmissionWorkload(snapshot).report("accessibility")
        let expected = try #require(
            view.accessibilityChildren() as? [MacAccessibilityElement]
        )
        let frames = try expected.map(MacAccessibilityGeometryTestSupport.frame)
        _ = try MacAdmissionMeasurement.measure(
            "accessibility",
            prepare: { _ in snapshot.presentedDocument },
            action:
            {
                MacAccessibilityTree.elements(
                    document: $0,
                    view: view,
                    horizontalInset: view.horizontalInset
                )
            },
            consume:
            {
                _, elements in
                #expect(elements.count == expected.count)
                let actualFrames = try elements.map(
                    MacAccessibilityGeometryTestSupport.frame
                )
                #expect(actualFrames == frames)
                let first = try #require(elements.first)
                let actual = try MacAccessibilityGeometryTestSupport
                    .frame(first)
                let expected = try MacAccessibilityGeometryTestSupport
                    .expectedFirstFrame(
                    view
                )
                #expect(actual == expected)
            }
        )
        #expect(view.model.snapshot == snapshot)
        #expect(view.model.layoutExecutionCount == layouts)
        MacReaderRasterPublicationTests.expectSameExecution(
            execution,
            view.model.rasterExecution
        )
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
    }
}
