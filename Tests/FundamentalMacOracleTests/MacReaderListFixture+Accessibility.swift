import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacReaderListFixture
{
    static func expectGroup(
        _ group: MacAccessibilityElement, text: String,
        index: Int, label: String, marker: Bool = true
    ) throws
    {
        #expect(group.accessibilityAttributeValue(.role)
            as? NSAccessibility.Role == .group)
        #expect(group.accessibilityIndex() == index)
        #expect((group.accessibilityAttributeValue(.index) as? NSNumber)?
            .intValue == index)
        let nodes = try children(group)
        try #require(nodes.count == (marker ? 2 : 1))
        let body = try #require(nodes.last)
        #expect(body.accessibilityAttributeValue(.role)
            as? NSAccessibility.Role == .staticText)
        let value = try #require(body.accessibilityAttributeValue(.value)
            as? String)
        #expect(value.utf16.elementsEqual(text.utf16))
        #expect(body.accessibilityIndex() == index)
        #expect(body.accessibilityNumberOfCharacters() == text.utf16.count)
        #expect(body.accessibilityAttributeValue(.parent)
            as? MacAccessibilityElement === group)
        let attributed = try #require(body.accessibilityAttributedString(
            for: NSRange(location: 0, length: text.utf16.count)
        ))
        #expect(attributed.string.utf16.elementsEqual(text.utf16))
        if !text.isEmpty
        {
            let attributes = attributed.attributes(at: 0, effectiveRange: nil)
            #expect((attributes[.accessibilityListItemPrefix]
                as? NSAttributedString)?.string == label)
            #expect((attributes[.accessibilityListItemIndex]
                as? NSNumber)?.intValue == index)
            #expect((attributes[.accessibilityListItemLevel]
                as? NSNumber)?.intValue == 0)
        }
        if marker
        {
            let prefix = nodes[0]
            #expect(prefix.accessibilityAttributeValue(.role)
                as? NSAccessibility.Role == .listMarkerRole)
            #expect(prefix.accessibilityAttributeValue(.value)
                as? String == label)
            #expect(prefix.accessibilityIndex() == index)
            #expect(prefix.accessibilityAttributeValue(.parent)
                as? MacAccessibilityElement === group)
        }
    }
}
