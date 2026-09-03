import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutGridRuleTests
{
    @MainActor
    @Test("horizontal ownership removes every rule intersection")
    func intersections() throws
    {
        let block = SemanticBlock.table(
            try LayoutFixture.table(captioned: true)
        )
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 360)
        )
        let rules: [LayoutRectangle]
        rules = snapshot.fragments.compactMap
        {
            guard case let .grid(fragment) = $0,
                  case .rule = fragment.content
            else
            {
                return nil
            }
            return fragment.frame
        }
        for first in rules.indices
        {
            for second in rules.indices where second > first
            {
                #expect(!rules[first].intersects(rules[second]))
            }
        }
    }
}
