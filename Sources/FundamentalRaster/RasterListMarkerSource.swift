package struct RasterListMarkerSource: Equatable, Sendable
{
    package let residentID: RasterResidentID
    package let position: RasterListPosition
    private let numbered: Bool

    package var role: RasterInteractionRole
    {
        numbered ? .numbered(position) : .bulleted(position)
    }

    package var label: String
    {
        numbered ? "\(position.number)." : "•"
    }

    package init?(
        residentID: RasterResidentID, role: RasterInteractionRole
    )
    {
        guard residentID.blockOrdinal >= 0,
              residentID.fragmentOrdinal == 0
        else
        {
            return nil
        }
        switch role
        {
        case let .bulleted(position):
            self.position = position
            numbered = false
        case let .numbered(position):
            self.position = position
            numbered = true
        default:
            return nil
        }
        self.residentID = residentID
    }
}
