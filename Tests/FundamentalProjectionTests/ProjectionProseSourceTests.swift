import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalProjection

struct ProjectionProseSourceTests
{
    @Test func everyProseRoleRetainsOriginalRuns() throws
    {
        let runs = [
            ProjectionFixture.direct("extra", traits: [.strong]),
            ProjectionFixture.direct("", traits: [.inlineCode]),
            try ProjectionFixture.scoped("ordinary\u{AD} 👩‍💻 "),
            ProjectionFixture.direct("раи"),
            try ProjectionFixture.scoped("\u{306}он\r\n"),
            ProjectionFixture.direct(""),
            ProjectionFixture.direct("")
        ]
        let blocks = [
            SemanticBlock.paragraph(.init(runs: runs)),
            .heading(.title(.init(runs: runs))),
            .listItem(.init(kind: .bulleted, runs: runs)),
            .listItem(.init(kind: .numbered, runs: runs))
        ] + SemanticHeadingLevel.allCases.map
        {
            SemanticBlock.heading(.section(.init(runs: runs, level: $0)))
        }
        let snapshot = try ProjectionFixture.snapshot(blocks)
        let projection = ProjectionSnapshot(snapshot)
        for block in projection.blocks
        {
            guard case let .prose(source, prose) = block
            else
            {
                Issue.record("Expected prose")
                continue
            }
            #expect(prose.paragraph.runs == runs)
            #expect(prose.runs.count == runs.count)
            #expect(prose.runs.map(\.text) == runs.map(\.text))
            var offset = 0
            for (index, run) in prose.runs.enumerated()
            {
                guard case let .block(blockID, ordinal, range) = run.source
                else
                {
                    Issue.record("Expected block run source")
                    continue
                }
                #expect(blockID == source.blockID)
                #expect(ordinal == index)
                #expect(range.value == offset..<(offset + run.text.utf16.count))
                #expect(run.traits == Set(
                    runs[index].traits.map(ProjectionSnapshot.project)
                ))
                offset += run.text.utf16.count
            }
        }
        #expect(projection.lineage.documentID
            == snapshot.document.documentID.value)
    }

    @Test func constructorBindsOneSourceAndRetainsValueIndependence() throws
    {
        var runs = [ProjectionFixture.direct("original")]
        let prose = ProjectedProse(
            role: .body, runs: runs, blockID: ProjectionFixture.blockID(0)
        )
        runs[0] = ProjectionFixture.direct("changed")
        #expect(prose.paragraph.runs.map(\.text) == ["original"])
        #expect(prose.runs.map(\.text) == ["original"])
        for values: [SemanticRun] in [[], [
            ProjectionFixture.direct(""), ProjectionFixture.direct("")
        ]]
        {
            let empty = ProjectedProse(
                role: .body, runs: values, blockID: ProjectionFixture.blockID(0)
            )
            #expect(empty.paragraph.runs == values)
            #expect(empty.runs.count == values.count)
        }
    }
}
