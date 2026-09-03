package enum LayoutGridFragmentContent: Equatable, Sendable
{
    case region
    case captionLine(LayoutLine)
    case cell(LayoutCell)
    case cellLine(LayoutGridLine)
}
