import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

extension MacReaderRasterPublicationTests
{
    static func positions(
        in model: MacReaderModel
    ) throws -> (PresentationTextPosition, PresentationTextPosition)
    {
        let (resident, line) = try MacReaderInteractionTests.line(
            in: model.snapshot
        )
        let first = try #require(line.caretSites.first)
        let last = try #require(line.caretSites.last)
        return (
            PresentationTextPosition(
                residentID: resident.residentID,
                sourcePoint: first.sourcePoint
            ),
            PresentationTextPosition(
                residentID: resident.residentID,
                sourcePoint: last.sourcePoint
            )
        )
    }

    static func expectSameExecution(
        _ expected: MacAdmittedRasterExecution,
        _ actual: MacAdmittedRasterExecution
    )
    {
        #expect(expected.lineage == actual.lineage)
        #expect(expected.documentExecution === actual.documentExecution)
        switch (expected, actual)
        {
        case (.document, .document):
            return
        case let (.caret(_, _, left), .caret(_, _, right)):
            #expect(left.source == right.source)
        case let (.selection(_, _, left), .selection(_, _, right)):
            #expect(left.source == right.source)
        default:
            Issue.record("The execution form changed")
        }
    }
}
