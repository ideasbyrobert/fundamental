import FundamentalProjection

extension NativeTextKit2Layout
{
    func columnExtent(
        count: Int,
        parameters: LayoutParameters
    ) throws -> Double
    {
        guard count > 0
        else
        {
            return 0
        }
        let minimum = parameters.cellPadding * 2 + 1
        let totalSpacing = parameters.columnSpacing
            * Double(count - 1)
        let requested = (parameters.width - totalSpacing)
            / Double(count)
        let extent = max(minimum, requested)
        guard extent.isFinite
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        return extent
    }

    func columnTracks(
        _ content: ProjectedTableContent,
        count: Int,
        extent: Double,
        spacing: Double
    ) throws -> [LayoutColumnTrack]
    {
        try (0 ..< count).map
        {
            index in
            let origin = Double(index) * (extent + spacing)
            guard origin.isFinite
            else
            {
                throw LayoutFailure.nonfiniteNativeGeometry
            }
            let alignment = index < content.columnAlignments.count
                ? content.columnAlignments[index]
                : .unspecified
            return LayoutColumnTrack(
                index: index,
                alignment: alignment,
                origin: origin,
                extent: extent
            )
        }
    }

    func rowTracks(
        count: Int,
        headerCount: Int,
        heights: [Double],
        originY: Double,
        spacing: Double
    ) throws -> [LayoutRowTrack]
    {
        var result: [LayoutRowTrack] = []
        var y = originY
        for index in 0 ..< count
        {
            result.append(LayoutRowTrack(
                index: index,
                scope: index < headerCount ? .header : .body,
                origin: y,
                extent: heights[index]
            ))
            y += heights[index]
            if index + 1 < count
            {
                y += spacing
            }
            guard y.isFinite
            else
            {
                throw LayoutFailure.nonfiniteNativeGeometry
            }
        }
        return result
    }
}
