package enum LayoutGridFragmentContent: Equatable, Sendable
{
    case region
    case captionLine(LayoutLine)
    case columnTrack(LayoutColumnTrack)
    case rowTrack(LayoutRowTrack)
    case cell(LayoutCell)
    case cellLine(LayoutGridLine)
    case rule(LayoutGridRuleOwner)
}
