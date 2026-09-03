extension PresentationComposer
{
    static func caret(
        at position: PresentationTextPosition,
        document: PresentedDocument,
        specification: PresentationSpecificationIdentity
    ) -> PresentationCaretAdornment?
    {
        guard let resident = document.residents.all.first(where:
        {
            $0.residentID == position.residentID
        }),
              let line = residentText(resident.content),
              let site = exactCaret(
                  position.sourcePoint,
                  line: line
              ),
              let size = PresentationSize(
                  width: specification.caretWidth,
                  height: line.lineBounds.size.height
              ),
              let origin = PresentationPoint(
                  x: site.position.x,
                  y: line.lineBounds.minY
              ),
              let bounds = PresentationRectangle(
                  origin: origin,
                  size: size
              )
        else
        {
            return nil
        }
        return PresentationCaretAdornment(
            position: position,
            sitePosition: site.position,
            lineBounds: line.lineBounds,
            logicalBounds: bounds,
            color: specification.adornmentPalette.caret
        )
    }

    static func residentText(
        _ content: PresentedResidentContent
    ) -> PresentedTextLine?
    {
        switch content
        {
        case let .body(line):
            return line
        case let .title(line):
            return line
        case let .section(_, line):
            return line
        case let .code(line):
            return line
        case let .caption(line):
            return line
        case let .headerCell(_, _, .line(line)):
            return line
        case let .bodyCell(_, _, .line(line)):
            return line
        case .table,
             .tableColumn,
             .headerRow,
             .bodyRow,
             .headerCell(_, _, .area),
             .bodyCell(_, _, .area):
            return nil
        }
    }

    static func exactCaret(
        _ point: PresentationTextPoint,
        line: PresentedTextLine
    ) -> PresentedCaretSite?
    {
        let matches = line.caretSites.filter
        {
            $0.sourcePoint == point
        }
        guard matches.count == 1
        else
        {
            return nil
        }
        return matches[0]
    }
}
