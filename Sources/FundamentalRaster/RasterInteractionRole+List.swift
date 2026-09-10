extension RasterInteractionRole
{
    package var listPosition: RasterListPosition?
    {
        switch self
        {
        case let .bulleted(position), let .numbered(position):
            position
        default:
            nil
        }
    }
}
