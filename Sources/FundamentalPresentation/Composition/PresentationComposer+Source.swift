import FundamentalRaster

extension PresentationComposer
{
    static func residentID(
        _ value: RasterResidentID
    ) -> PresentationResidentID?
    {
        PresentationResidentID(
            blockID: value.blockID,
            blockOrdinal: value.blockOrdinal,
            fragmentOrdinal: value.fragmentOrdinal
        )
    }

    static func sourceSlice(
        _ value: RasterSourceSlice
    ) -> PresentationSourceSlice?
    {
        guard value.range.lowerBound >= 0,
              value.range.lowerBound < value.range.upperBound,
              value.text.utf16.count == value.range.count,
              let source = textSource(value.source),
              source.sourceRange.contains(value.range.lowerBound),
              source.sourceRange.upperBound >= value.range.upperBound,
              let scope = runScope(value.scope)
        else
        {
            return nil
        }
        return PresentationSourceSlice(
            source: source,
            scope: scope,
            range: value.range,
            text: value.text
        )
    }

    static func sourceSlices(
        _ values: [RasterSourceSlice]
    ) -> [PresentationSourceSlice]?
    {
        var slices: [PresentationSourceSlice] = []
        slices.reserveCapacity(values.count)
        for value in values
        {
            guard let slice = sourceSlice(value)
            else
            {
                return nil
            }
            slices.append(slice)
        }
        return slices
    }

    static func textSource(
        _ value: RasterTextSource
    ) -> PresentationTextSource?
    {
        switch value
        {
        case let .block(blockID, run, range):
            guard validSource(run: run, range: range)
            else
            {
                return nil
            }
            return .block(blockID: blockID, run: run, range: range)
        case let .caption(blockID, run, range):
            guard validSource(run: run, range: range)
            else
            {
                return nil
            }
            return .caption(blockID: blockID, run: run, range: range)
        case let .cell(blockID, row, cell, run, range):
            guard row >= 0,
                  cell >= 0,
                  validSource(run: run, range: range)
            else
            {
                return nil
            }
            return .cell(
                blockID: blockID,
                row: row,
                cell: cell,
                run: run,
                range: range
            )
        }
    }

    static func textPoint(
        _ value: RasterTextPoint
    ) -> PresentationTextPoint?
    {
        switch value
        {
        case let .block(blockID, offset):
            guard offset >= 0
            else
            {
                return nil
            }
            return .block(blockID: blockID, utf16Offset: offset)
        case let .caption(blockID, offset):
            guard offset >= 0
            else
            {
                return nil
            }
            return .caption(blockID: blockID, utf16Offset: offset)
        case let .cell(blockID, row, cell, offset):
            guard row >= 0,
                  cell >= 0,
                  offset >= 0
            else
            {
                return nil
            }
            return .cell(
                blockID: blockID,
                row: row,
                cell: cell,
                utf16Offset: offset
            )
        }
    }

    static func runScope(
        _ value: RasterRunScope
    ) -> PresentationRunScope?
    {
        switch value
        {
        case .direct:
            return .direct
        case let .link(destination):
            guard nonblank(destination)
            else
            {
                return nil
            }
            return .link(destination)
        case let .language(identifier):
            guard nonblank(identifier)
            else
            {
                return nil
            }
            return .language(identifier)
        case let .linkAndLanguage(link, language):
            guard nonblank(link),
                  nonblank(language)
            else
            {
                return nil
            }
            return .linkAndLanguage(
                link: link,
                language: language
            )
        }
    }

    static func nonblank(_ value: String) -> Bool
    {
        value.contains
        {
            !$0.isWhitespace
        }
    }

    static func validSource(
        run: Int,
        range: Range<Int>
    ) -> Bool
    {
        run >= 0
            && range.lowerBound >= 0
            && range.lowerBound < range.upperBound
    }
}
