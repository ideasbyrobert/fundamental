import FundamentalRaster

extension PresentationComposer
{
    static func resident(
        _ value: RasterInteractionRegion,
        marks: [PresentationMark],
        reusable: [PresentationResidentID: PresentedResidentStorage]
    ) -> PresentedResident?
    {
        guard let identifier = residentID(value.residentID),
              let frame = rectangle(value.frame),
              let content = residentContent(
                  role: value.role,
                  content: value.content,
                  residentID: identifier
              ),
              marks.allSatisfy(
              {
                  $0.residentID == identifier
              }),
              validMarkSources(
                  marks,
                  residentID: identifier,
                  content: content
              )
        else
        {
            return nil
        }
        let candidate = PresentedResidentStorage(
            residentID: identifier,
            frame: frame,
            content: content,
            marks: marks
        )
        let storage: PresentedResidentStorage
        if let previous = reusable[identifier],
           previous == candidate
        {
            storage = previous
        }
        else
        {
            storage = candidate
        }
        return PresentedResident(
            residence: residence(value.residence),
            storage: storage
        )
    }

    static func residentContent(
        role: RasterInteractionRole,
        content: RasterInteractionContent,
        residentID: PresentationResidentID
    ) -> PresentedResidentContent?
    {
        switch (role, content)
        {
        case let (.body, .text(value)):
            return textContent(value, domain: .block(residentID.blockID))
                .map(PresentedResidentContent.body)
        case let (.title, .text(value)):
            return textContent(value, domain: .block(residentID.blockID))
                .map(PresentedResidentContent.title)
        case let (.section(level), .text(value)):
            guard let level = headingLevel(level),
                  let line = textContent(
                      value,
                      domain: .block(residentID.blockID)
                  )
            else
            {
                return nil
            }
            return .section(level, line)
        case let (.code, .text(value)):
            return textContent(value, domain: .block(residentID.blockID))
                .map(PresentedResidentContent.code)
        case (.table, .region):
            return .table
        case let (.caption, .text(value)):
            return textContent(
                value,
                domain: .caption(residentID.blockID)
            ).map(PresentedResidentContent.caption)
        case let (.tableColumn(index), .columnTrack(value)):
            guard let column = tableColumn(value),
                  column.index == index
            else
            {
                return nil
            }
            return .tableColumn(column)
        case let (.headerRow(index), .rowTrack(value)):
            guard let row = tableRow(value),
                  row.index == index
            else
            {
                return nil
            }
            return .headerRow(row)
        case let (.bodyRow(index), .rowTrack(value)):
            guard let row = tableRow(value),
                  row.index == index
            else
            {
                return nil
            }
            return .bodyRow(row)
        case let (.headerCell(row, cell), .cell(value)):
            return cellArea(value, row: row, cell: cell).map
            {
                .headerCell(row: row, cell: cell, content: .area($0))
            }
        case let (.bodyCell(row, cell), .cell(value)):
            return cellArea(value, row: row, cell: cell).map
            {
                .bodyCell(row: row, cell: cell, content: .area($0))
            }
        case let (.headerCell(row, cell), .text(value)):
            return cellLine(
                value,
                blockID: residentID.blockID,
                row: row,
                cell: cell
            ).map
            {
                .headerCell(row: row, cell: cell, content: .line($0))
            }
        case let (.bodyCell(row, cell), .text(value)):
            return cellLine(
                value,
                blockID: residentID.blockID,
                row: row,
                cell: cell
            ).map
            {
                .bodyCell(row: row, cell: cell, content: .line($0))
            }
        default:
            return nil
        }
    }

    static func residence(
        _ value: RasterResidence
    ) -> PresentationResidence
    {
        switch value
        {
        case .visible:
            .visible
        case .overscan(.preceding):
            .overscan(.preceding)
        case .overscan(.following):
            .overscan(.following)
        }
    }

    static func headingLevel(
        _ value: RasterHeadingLevel
    ) -> PresentationHeadingLevel?
    {
        PresentationHeadingLevel(rawValue: value.rawValue)
    }
}
