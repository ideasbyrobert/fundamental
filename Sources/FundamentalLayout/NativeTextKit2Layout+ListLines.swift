import FundamentalProjection

extension NativeTextKit2Layout
{
    func listLines(
        _ prose: ProjectedProse,
        source: LayoutListMarkerSource,
        width: Double,
        originY: Double
    ) throws -> [LayoutLine]
    {
        let font = try proseFont(prose.role)
        let measure = try NativeListMeasure(source: source, font: font)
        guard width.isFinite
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        guard width > measure.inset
        else
        {
            throw LayoutFailure.unrepresentableListGeometry
        }
        let lines = try textLines(
            runs: prose.runs, width: width - measure.inset,
            originX: measure.inset, originY: originY, font: font,
            pointContext: .block(source.block.blockID)
        )
        for line in lines
        {
            try validateListLine(line, inset: measure.inset, width: width)
        }
        guard let first = lines.first
        else
        {
            throw LayoutFailure.missingNativeLine
        }
        let marker = try listMarker(source, baselineX: 0,
                                    baselineY: first.baseline.y)
        let placed = try translated(
            marker, dx: measure.column - marker.advance, dy: 0
        )
        guard marker.advance <= measure.column,
              placed.inkBounds.minX >= 0,
              placed.inkBounds.maxX <= measure.column
        else
        {
            throw LayoutFailure.unrepresentableListGeometry
        }
        return [try listLine(first, marker: placed)] + lines.dropFirst()
    }
}
