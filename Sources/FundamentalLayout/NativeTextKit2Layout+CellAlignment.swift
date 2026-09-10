import FundamentalProjection

extension NativeTextKit2Layout
{
    func resolvedAlignment(
        _ placement: NativeGridPlacement,
        columns: [LayoutColumnTrack]
    ) -> ProjectedTableColumnAlignment
    {
        let selected = placement.alignment == .unspecified
            ? columns[placement.columnTrack].alignment
            : placement.alignment
        return selected == .unspecified ? .leading : selected
    }

    func alignmentOffset(
        _ alignment: ProjectedTableColumnAlignment,
        contentWidth: Double,
        lineWidth: Double
    ) -> Double
    {
        let available = max(0, contentWidth - lineWidth)
        switch alignment
        {
        case .leading, .unspecified:
            return 0
        case .center:
            return available * 0.5
        case .trailing:
            return available
        }
    }
}
