import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func expectContent(
        _ source: RasterInteractionContent,
        role: RasterInteractionRole,
        equals result: PresentedResidentContent
    )
    {
        switch source
        {
        case .region:
            guard case .table = role,
                  case .table = result
            else
            {
                Issue.record("Expected the table region")
                return
            }
        case let .text(text):
            expectTextContent(text, role: role, equals: result)
        case let .columnTrack(column):
            expectColumn(column, role: role, equals: result)
        case let .rowTrack(row):
            expectRow(row, role: role, equals: result)
        case let .cell(cell):
            expectCell(cell, role: role, equals: result)
        }
    }
}
