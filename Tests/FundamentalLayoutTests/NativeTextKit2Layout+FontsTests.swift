import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("Reader list layout retains list identity")
struct NativeListLayoutTests
{
    @MainActor
    @Test("body and list lines share a font without losing list markers")
    func listFonts() throws
    {
        for kind in SemanticListKind.allCases
        {
            let projection = try LayoutFixture.projection([
                .paragraph(SemanticParagraph(runs: [
                    SemanticRun(text: "Before")
                ])),
                .listItem(SemanticListItem(
                    kind: kind, runs: [SemanticRun(text: "Item")]
                ))
            ])
            let request = try LayoutFixture.request(width: 600)
            let snapshot = try NativeTextKit2Layout().layout(
                projection, request: request
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
            #expect(lines.count == 2)
            #expect(lines[0].marker == nil)
            #expect(lines[1].marker != nil)
            #expect(lines[0].defaultFont == lines[1].defaultFont)
        }
    }
}
