import FundamentalViewport

extension ViewportRasterizer
{
    static func admits(
        _ viewport: ViewportSnapshot,
        targetBounds: RasterRectangle,
        capacities: RasterCapacities
    ) -> Bool
    {
        var budget = RasterAdmissionBudget(capacities: capacities)
        let (residentCount, residentOverflow) = viewport.residents.remaining
            .count.addingReportingOverflow(1)
        guard !residentOverflow
        else
        {
            return false
        }
        for residentIndex in 0 ..< residentCount
        {
            let resident = residentIndex == 0
                ? viewport.residents.first
                : viewport.residents.remaining[residentIndex - 1]
            guard let frame = rectangle(
                x: resident.fragment.frame.minX,
                y: resident.fragment.frame.minY,
                width: resident.fragment.frame.size.width,
                height: resident.fragment.frame.size.height
            )
            else
            {
                return false
            }
            if case let .grid(fragment) = resident.fragment,
               case .rule = fragment.content
            {
                guard Self.consumeFill(
                    frame,
                    targetBounds: targetBounds,
                    budget: &budget
                )
                else
                {
                    return false
                }
                continue
            }
            guard budget.consumeInteractionRegion()
            else
            {
                return false
            }
            switch resident.fragment
            {
            case let .lines(fragment):
                guard Self.admits(
                    fragment.line,
                    targetBounds: targetBounds,
                    budget: &budget
                )
                else
                {
                    return false
                }
                continue
            case let .grid(fragment):
                switch fragment.content
                {
                case let .captionLine(line):
                    guard Self.admits(
                        line,
                        targetBounds: targetBounds,
                        budget: &budget
                    )
                    else
                    {
                        return false
                    }
                    continue
                case let .cellLine(line):
                    guard Self.admits(
                        line.line,
                        targetBounds: targetBounds,
                        budget: &budget
                    )
                    else
                    {
                        return false
                    }
                    continue
                case .region, .columnTrack, .rowTrack, .cell, .rule:
                    break
                }
            }
            guard case let .grid(fragment) = resident.fragment
            else
            {
                return false
            }
            switch fragment.content
            {
            case .region:
                guard Self.consumeFill(
                    frame,
                    targetBounds: targetBounds,
                    budget: &budget
                )
                else
                {
                    return false
                }
            case let .rowTrack(track):
                if track.scope == .header,
                   !Self.consumeFill(
                       frame,
                       targetBounds: targetBounds,
                       budget: &budget
                   )
                {
                    return false
                }
            case .cell:
                break
            case .columnTrack:
                break
            case .captionLine, .cellLine, .rule:
                return false
            }
        }
        return true
    }

    private static func admits(
        _ line: ResidentLayoutLine,
        targetBounds: RasterRectangle,
        budget: inout RasterAdmissionBudget
    ) -> Bool
    {
        let (caretCount, caretOverflow) = line.remainingCaretStops.count
            .addingReportingOverflow(1)
        guard !caretOverflow,
              budget.consumeText(line.text),
              budget.consumeCaretSites(caretCount),
              budget.consumeFont(
                  postScriptName: line.defaultFont.postScriptName,
                  uniqueName: line.defaultFont.uniqueName,
                  versionName: line.defaultFont.versionName,
                  variationCount: line.defaultFont.variations.count
              ),
              Self.admits(
                  line.sourceSlices,
                  budget: &budget
              )
        else
        {
            return false
        }
        for run in line.glyphRuns
        {
            let (glyphCount, glyphOverflow) = run.remainingGlyphs.count
                .addingReportingOverflow(1)
            guard !glyphOverflow,
                  budget.consumeMarks(1),
                  budget.consumeGlyphs(glyphCount),
                  budget.consumeFont(
                      postScriptName: run.font.postScriptName,
                      uniqueName: run.font.uniqueName,
                      versionName: run.font.versionName,
                      variationCount: run.font.variations.count
                  ),
                  Self.admits(run.sourceSlices, budget: &budget)
            else
            {
                return false
            }
            for glyphIndex in 0 ..< glyphCount
            {
                let glyph = glyphIndex == 0
                    ? run.firstGlyph
                    : run.remainingGlyphs[glyphIndex - 1]
                guard Self.admits(
                    glyph.sourceSlices,
                    budget: &budget
                )
                else
                {
                    return false
                }
            }
            for decoration in run.decorations
            {
                guard let bounds = rectangle(
                    x: decoration.frame.minX,
                    y: decoration.frame.minY,
                    width: decoration.frame.size.width,
                    height: decoration.frame.size.height
                )
                else
                {
                    return false
                }
                if bounds.intersection(targetBounds) != nil,
                   (!budget.consumeFill()
                       || !Self.admits(
                           decoration.sourceSlices,
                           budget: &budget
                       ))
                {
                    return false
                }
            }
        }
        return true
    }

    private static func admits(
        _ slices: [ResidentLayoutSourceSlice],
        budget: inout RasterAdmissionBudget
    ) -> Bool
    {
        for slice in slices
        {
            guard budget.consumeSourceSlice(slice.text)
            else
            {
                return false
            }
            for payload in slice.scopePayloads
            {
                guard budget.consumeText(payload)
                else
                {
                    return false
                }
            }
        }
        return true
    }

    private static func consumeFill(
        _ bounds: RasterRectangle?,
        targetBounds: RasterRectangle,
        budget: inout RasterAdmissionBudget
    ) -> Bool
    {
        guard let bounds,
              bounds.intersection(targetBounds) != nil
        else
        {
            return bounds != nil
        }
        return budget.consumeFill()
    }

}
