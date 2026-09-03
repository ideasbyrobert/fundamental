import Testing

@testable import FundamentalDocument
@testable import FundamentalProjection

extension ProjectionProseTests
{
    @Test("consecutive empty runs retain distinct source identities")
    func consecutiveEmptyRunsRetainDistinctSourceIdentities() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            ProjectionFixture.direct(""),
            ProjectionFixture.direct("")
        ]))
        let projection = try ProjectionFixture.projection([block])
        guard case let .prose(_, prose) = projection.firstBlock,
              case let .direct(firstSource, _, _) = prose.runs[0],
              case let .direct(secondSource, _, _) = prose.runs[1],
              case let .block(firstID, firstRun, firstRange) = firstSource,
              case let .block(secondID, secondRun, secondRange) = secondSource
        else
        {
            Issue.record("Expected two direct block runs")
            return
        }

        #expect(firstID == secondID)
        #expect(firstRange == secondRange)
        #expect(firstRun == 0)
        #expect(secondRun == 1)
        #expect(firstSource != secondSource)
    }
}
