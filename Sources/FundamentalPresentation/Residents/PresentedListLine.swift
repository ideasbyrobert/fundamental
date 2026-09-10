package enum PresentedListLine: Equatable, Sendable
{
    case first(PresentationListMarker, PresentedTextLine)
    case continuation(PresentedTextLine)

    package var textLine: PresentedTextLine
    {
        switch self
        {
        case let .first(_, line), let .continuation(line):
            line
        }
    }

    package var marker: PresentationListMarker?
    {
        if case let .first(marker, _) = self
        {
            return marker
        }
        return nil
    }
}
