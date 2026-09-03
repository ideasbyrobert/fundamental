@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func pointSignature(_ value: RasterTextPoint) -> String
    {
        switch value
        {
        case let .block(id, offset):
            return "block:\(id):\(offset)"
        case let .caption(id, offset):
            return "caption:\(id):\(offset)"
        case let .cell(id, row, cell, offset):
            return "cell:\(id):\(row):\(cell):\(offset)"
        }
    }

    func pointSignature(_ value: PresentationTextPoint) -> String
    {
        switch value
        {
        case let .block(id, offset):
            return "block:\(id):\(offset)"
        case let .caption(id, offset):
            return "caption:\(id):\(offset)"
        case let .cell(id, row, cell, offset):
            return "cell:\(id):\(row):\(cell):\(offset)"
        }
    }
}
