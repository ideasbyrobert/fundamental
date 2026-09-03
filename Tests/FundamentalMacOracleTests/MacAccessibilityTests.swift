import AppKit
import Testing

@testable import FundamentalMacOracle

@Suite("The resident native accessibility tree", .serialized)
@MainActor
struct MacAccessibilityTests
{
    @Test("title and sections expose only their actual heading facts")
    func headingsExposeNativeSemantics() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        controller.showWindow(nil)
        controller.synchronize()
        let nodes = try elements(controller.readerView)
        let title = try #require(nodes.first
        {
            guard case .title = $0.semantics
            else
            {
                return false
            }
            return true
        })
        #expect(role(title) == .headingRole)
        #expect(value(title) == "Fundamental")
        #expect((title.accessibilityAttributeValue(
            .headingLevelAttribute
        ) as? NSNumber)?.intValue == 1)
        let levels = nodes.compactMap
        {
            element -> Int? in
            guard case .section = element.semantics,
                  role(element) == .headingRole
            else
            {
                return nil
            }
            return (element.accessibilityAttributeValue(
                .headingLevelAttribute
            ) as? NSNumber)?.intValue
        }
        #expect(Set(levels) == Set(1 ... 6))
        window.close()
    }

    func elements(
        _ view: MacReaderView
    ) throws -> [MacAccessibilityElement]
    {
        guard let values = view.accessibilityChildren()
                as? [MacAccessibilityElement]
        else
        {
            throw MacOracleTestFailure.admission
        }
        return values
    }

    func role(
        _ element: MacAccessibilityElement
    ) -> NSAccessibility.Role?
    {
        element.accessibilityAttributeValue(.role)
            as? NSAccessibility.Role
    }

    func value(
        _ element: MacAccessibilityElement
    ) -> String?
    {
        element.accessibilityAttributeValue(.value) as? String
    }
}
