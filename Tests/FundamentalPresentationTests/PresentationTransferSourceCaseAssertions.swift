@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func sourceSignature(_ value: RasterTextSource) -> String
    {
        switch value
        {
        case let .block(id, run, range):
            return "block:\(id):\(run):\(range)"
        case let .caption(id, run, range):
            return "caption:\(id):\(run):\(range)"
        case let .cell(id, row, cell, run, range):
            return "cell:\(id):\(row):\(cell):\(run):\(range)"
        }
    }

    func sourceSignature(_ value: PresentationTextSource) -> String
    {
        switch value
        {
        case let .block(id, run, range):
            return "block:\(id):\(run):\(range)"
        case let .caption(id, run, range):
            return "caption:\(id):\(run):\(range)"
        case let .cell(id, row, cell, run, range):
            return "cell:\(id):\(row):\(cell):\(run):\(range)"
        }
    }
}
