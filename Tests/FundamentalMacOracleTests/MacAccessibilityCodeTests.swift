import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacAccessibilityTests
{
    @Test("prose and code are truthful native static text")
    func proseAndCodeAreNativeText() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        controller.showWindow(nil)
        var proseValues: [String] = []
        var codeValues: [String] = []
        let finalOrigin = max(
            0,
            controller.readerView.model.documentHeight - 680
        )
        let origins = Array(stride(
            from: 0.0,
            through: finalOrigin,
            by: 500
        )) + [finalOrigin]
        for origin in origins
        {
            controller.scrollView.contentView.scroll(
                to: NSPoint(x: 0, y: origin)
            )
            controller.synchronize()
            for node in try elements(controller.readerView)
            {
                switch node.semantics
                {
                case .body:
                    #expect(role(node) == .staticText)
                    proseValues.append(try #require(value(node)))
                case .code:
                    #expect(role(node) == .staticText)
                    codeValues.append(try #require(value(node)))
                default:
                    break
                }
            }
        }
        #expect(proseValues.contains
        {
            $0.contains("Numbers 0123456789")
        })
        #expect(codeValues.contains
        {
            $0.contains("what is, is")
        })
        #expect(codeValues.contains
        {
            $0.contains("func finite")
        })
        window.close()
    }
}
