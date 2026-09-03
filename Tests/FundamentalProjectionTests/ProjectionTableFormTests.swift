import Testing

@testable import FundamentalProjection

extension ProjectionProseTests
{
    func verifyOuterForm(
        _ record: ProjectedTableRecord,
        captioned: Bool,
        sourced: Bool
    ) throws
    {
        if sourced
        {
            guard case let .sourced(_, evidence) = record
            else
            {
                Issue.record("Expected sourced table")
                return
            }
            verifyEvidence(evidence)
        }
        else
        {
            guard case .semantic = record
            else
            {
                Issue.record("Expected semantic table")
                return
            }
        }
        if captioned
        {
            guard case let .captioned(_, caption) = record.table
            else
            {
                Issue.record("Expected captioned table")
                return
            }
            #expect(caption.runs.map(\.text) == ["C😀"])
            let captionRange = ProjectedUTF16Range(0..<3)
            guard case let .caption(blockID, run, range)
                = caption.firstRun.source
            else
            {
                Issue.record("Expected caption source")
                return
            }
            #expect(blockID == ProjectionFixture.blockID(0))
            #expect(run == 0)
            #expect(range == captionRange)
        }
        else
        {
            guard case .regular = record.table
            else
            {
                Issue.record("Expected regular table")
                return
            }
        }
    }
}
