import FundamentalProjection

@MainActor
package struct NativeTextKit2Layout
{
    package init()
    {
    }

    package func layout(
        _ projection: ProjectionSnapshot,
        request: LayoutRequest
    ) throws -> LayoutSnapshot
    {
        let parameters = request.parameters
        var fragments: [LayoutFragment] = []
        var grids: [LayoutGrid] = []
        var nextY = 0.0
        for (blockIndex, block) in projection.blocks.enumerated()
        {
            if blockIndex > 0
            {
                nextY += parameters.blockSpacing
            }
            switch block
            {
            case let .prose(source, prose):
                let lines = try proseLines(
                    prose,
                    source: source,
                    width: parameters.width,
                    originY: nextY
                )
                fragments += try proseFragments(
                    lines: lines,
                    source: source,
                    role: prose.role,
                    width: parameters.width
                )
                nextY = lines.map(\.frame.maxY).max() ?? nextY
            case let .code(source, code):
                let lines = try codeLines(
                    code,
                    source: source,
                    width: parameters.width,
                    originY: nextY
                )
                fragments += try codeFragments(
                    lines: lines,
                    source: source,
                    width: parameters.width
                )
                nextY = lines.map(\.frame.maxY).max() ?? nextY
            case let .table(source, record):
                let laidGrid = try grid(
                    record.table,
                    source: source,
                    originY: nextY,
                    parameters: parameters
                )
                grids.append(laidGrid)
                fragments += try gridFragments(laidGrid)
                nextY = laidGrid.frame.maxY
            }
        }
        let maximumX = fragments.map(\.frame.maxX).max()
            ?? parameters.width
        guard let size = LayoutSize(
            width: max(parameters.width, maximumX),
            height: nextY
        )
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        let fonts = resolvedFonts(
            in: fragments,
            grids: grids
        )
        let specification = LayoutSpecificationIdentity(
            parameters: parameters,
            resolvedFonts: fonts
        )
        return LayoutSnapshot(
            lineage: LayoutLineage(
                projection: projection.lineage,
                generation: request.generation,
                specification: specification
            ),
            size: size,
            firstFragment: fragments[0],
            remainingFragments: Array(fragments.dropFirst()),
            grids: grids
        )
    }

    func proseFragments(
        lines: [LayoutLine],
        source: ProjectedBlockSource,
        role: ProjectedProseRole,
        width: Double
    ) throws -> [LayoutFragment]
    {
        try lines.enumerated().map
        {
            index, line in
            .lines(LayoutLineFragment(
                anchor: LayoutFragmentAnchor(
                    source: source,
                    fragmentOrdinal: index
                ),
                source: source,
                role: .prose(role),
                frame: try residencyFrame(line, width: width),
                line: line
            ))
        }
    }

    func codeFragments(
        lines: [LayoutLine],
        source: ProjectedBlockSource,
        width: Double
    ) throws -> [LayoutFragment]
    {
        try lines.enumerated().map
        {
            index, line in
            .lines(LayoutLineFragment(
                anchor: LayoutFragmentAnchor(
                    source: source,
                    fragmentOrdinal: index
                ),
                source: source,
                role: .code,
                frame: try residencyFrame(line, width: width),
                line: line
            ))
        }
    }

    func residencyFrame(
        _ line: LayoutLine,
        x: Double = 0,
        width: Double
    ) throws -> LayoutRectangle
    {
        try rectangle(
            x: x,
            y: line.frame.minY,
            width: width,
            height: line.frame.size.height
        )
    }

    func resolvedFonts(
        in fragments: [LayoutFragment],
        grids: [LayoutGrid]
    ) -> [LayoutFontIdentity]
    {
        var fonts: [LayoutFontIdentity] = []
        var seen: Set<LayoutFontIdentity> = []
        for fragment in fragments
        {
            switch fragment
            {
            case let .lines(fragment):
                appendFonts(
                    of: fragment.line,
                    to: &fonts,
                    seen: &seen
                )
            case let .grid(fragment):
                switch fragment.content
                {
                case .region:
                    break
                case let .captionLine(line):
                    appendFonts(of: line, to: &fonts, seen: &seen)
                case .columnTrack, .rowTrack, .rule:
                    break
                case .cell:
                    break
                case let .cellLine(gridLine):
                    appendFonts(
                        of: gridLine.line,
                        to: &fonts,
                        seen: &seen
                    )
                }
            }
        }
        for grid in grids where seen.insert(grid.structuralFont).inserted
        {
            fonts.append(grid.structuralFont)
        }
        return fonts
    }

    func appendFonts(
        of line: LayoutLine,
        to fonts: inout [LayoutFontIdentity],
        seen: inout Set<LayoutFontIdentity>
    )
    {
        let candidates = [line.defaultFont]
            + line.glyphRuns.map(\.font)
        for font in candidates where seen.insert(font).inserted
        {
            fonts.append(font)
        }
    }

    func rectangle(
        x: Double,
        y: Double,
        width: Double,
        height: Double
    ) throws -> LayoutRectangle
    {
        guard let origin = LayoutPoint(x: x, y: y),
              let size = LayoutSize(width: width, height: height),
              let rectangle = LayoutRectangle(
                  origin: origin,
                  size: size
              )
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        return rectangle
    }

    func point(
        x: Double,
        y: Double
    ) throws -> LayoutPoint
    {
        guard let point = LayoutPoint(x: x, y: y)
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        return point
    }
}
