import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle

@MainActor
enum MacReaderListFixture
{
    static func block(_ kind: SemanticListKind, _ text: String) -> SemanticBlock
    {
        .listItem(SemanticListItem(
            kind: kind, runs: [SemanticRun(text: text)]
        ))
    }

    static func groups(_ view: MacReaderView) throws
        -> [MacAccessibilityElement]
    {
        let nodes = try #require(
            view.accessibilityChildren() as? [MacAccessibilityElement]
        )
        return nodes.filter
        {
            $0.accessibilityAttributeValue(.role) as? NSAccessibility.Role
                == .group
        }
    }

    static func children(_ node: MacAccessibilityElement) throws
        -> [MacAccessibilityElement]
    {
        try #require(node.accessibilityAttributeValue(.children)
            as? [MacAccessibilityElement])
    }
}
