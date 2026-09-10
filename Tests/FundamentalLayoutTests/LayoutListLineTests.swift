import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("Source-preserving list line geometry")
struct LayoutListLineTests
{
    @MainActor
    @Test("list source survives wrapping and embedded paragraph boundaries")
    func sourceLayout() throws
    {
        for kind in SemanticListKind.allCases
        {
            for text in [
                "", "e\u{301}😀 Раздел", "First\nSecond",
                "Readable source continues across several visual lines.",
                "שלום עולם", "First שלום 123 last"
            ]
            {
                let projection = try LayoutFixture.projection([
                    .listItem(SemanticListItem(kind: kind, runs: [
                        LayoutFixture.direct(text)
                    ]))
                ])
                let snapshot = try NativeTextKit2Layout().layout(
                    projection, request: LayoutFixture.request(width: 180)
                )
                let lines = snapshot.fragments.compactMap
                {
                    fragment -> LayoutLine? in
                    guard case let .lines(value) = fragment
                    else
                    {
                        return nil
                    }
                    return value.line
                }
                LayoutListLineFixture.expectSource(
                    lines, text: text, block: projection.firstBlock.source
                )
                #expect(lines.compactMap(\.marker).count == 1)
                #expect(lines.first?.marker != nil)
                if text.utf16.count > 50
                {
                    #expect(lines.count > 1)
                }
            }
        }
    }
}
