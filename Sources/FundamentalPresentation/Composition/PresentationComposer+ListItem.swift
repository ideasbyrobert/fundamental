import FundamentalRaster

extension PresentationComposer
{
    static func listItem(
        _ value: RasterInteractionRole
    ) -> PresentationListItem?
    {
        let kind: PresentationListKind
        let source: RasterListPosition
        switch value
        {
        case let .bulleted(position):
            kind = .bulleted
            source = position
        case let .numbered(position):
            kind = .numbered
            source = position
        default:
            return nil
        }
        guard let position = PresentationListPosition(
            index: source.index, count: source.count
        )
        else
        {
            return nil
        }
        return PresentationListItem(kind: kind, position: position)
    }

    static func listContent(
        _ value: RasterInteractionText, role: RasterInteractionRole,
        residentID: PresentationResidentID
    ) -> PresentedResidentContent?
    {
        guard let item = listItem(role),
              let line = textContent(value, domain: .block(residentID.blockID))
        else
        {
            return nil
        }
        guard let marker = value.marker
        else
        {
            return .list(item, .continuation(line))
        }
        guard let marker = listMarker(marker)
        else
        {
            return nil
        }
        return .list(item, .first(marker, line))
    }
}
