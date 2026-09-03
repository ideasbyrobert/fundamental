@testable import FundamentalLayout
@testable import FundamentalRaster

extension RasterFixture
{
    static func expectedSlices(
        _ slices: [LayoutSourceSlice]
    ) -> [RasterSourceSlice]
    {
        slices.map
        {
            let source: RasterTextSource
            switch $0.source
            {
            case let .block(blockID, run, range):
                source = .block(
                    blockID: blockID,
                    run: run,
                    range: range.value
                )
            case let .caption(blockID, run, range):
                source = .caption(
                    blockID: blockID,
                    run: run,
                    range: range.value
                )
            case let .cell(blockID, row, cell, run, range):
                source = .cell(
                    blockID: blockID,
                    row: row,
                    cell: cell,
                    run: run,
                    range: range.value
                )
            }
            let scope: RasterRunScope
            switch $0.scope
            {
            case .direct:
                scope = .direct
            case let .link(destination):
                scope = .link(destination)
            case let .language(identifier):
                scope = .language(identifier)
            case let .linkAndLanguage(link, language):
                scope = .linkAndLanguage(
                    link: link,
                    language: language
                )
            }
            return RasterSourceSlice(
                source: source,
                scope: scope,
                range: $0.range,
                text: $0.text
            )
        }
    }
}
