import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("Projected line roles")
struct LayoutRoleTests
{
    @MainActor
    @Test("heading and code roles survive native line partitioning")
    func roles() throws
    {
        let blocks = [
            SemanticBlock.heading(.title(TitleSemanticHeading(runs: [
                LayoutFixture.direct("Title")
            ]))),
            .heading(.section(SectionSemanticHeading(
                runs: [LayoutFixture.direct("Section")],
                level: .three
            ))),
            .code(.plain(PlainSemanticCodeBlock(runs: [
                LayoutFixture.direct("let value = 1")
            ])))
        ]
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection(blocks),
            request: LayoutFixture.request(width: 500)
        )
        let fragments: [LayoutLineFragment] = snapshot.fragments.compactMap
        {
            guard case let .lines(fragment) = $0
            else
            {
                return nil
            }
            return fragment
        }
        #expect(fragments.map(\.role) == [
            .prose(.title),
            .prose(.section(.three)),
            .code
        ])
        #expect(fragments.map(\.source.ordinal) == [0, 1, 2])
        #expect(fragments[1].frame.minY > fragments[0].frame.maxY)
        #expect(fragments[2].frame.minY > fragments[1].frame.maxY)
        #expect(fragments[0].line.defaultFont.postScriptName
            != fragments[2].line.defaultFont.postScriptName)
    }
}
