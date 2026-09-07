import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("Unadmitted reader list layout refuses explicitly")
struct NativeListLayoutRefusalTests
{
    @MainActor
    @Test("the older reader cannot disguise a list as an ordinary paragraph")
    func unsupportedLists() throws
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
            #expect(throws: LayoutFailure.unsupportedProseRole)
            {
                try NativeTextKit2Layout().layout(projection, request: request)
            }
        }
    }
}
